import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/new_app.dart';

void main() {
  group('normalizeName', () {
    test('turns any spelling into a snake_case package name', () {
      expect(normalizeName('shopkart'), 'shopkart');
      expect(normalizeName('Shopkart'), 'shopkart');
      expect(normalizeName('My App'), 'my_app');
      expect(normalizeName('my-app'), 'my_app');
      expect(normalizeName('MyApp'), 'my_app');
      expect(normalizeName('  shop.v2!  '), 'shop_v2');
    });
  });

  group('derived names', () {
    test('display name and camelCase come from the snake_case name', () {
      expect(displayNameFrom('shopkart'), 'Shopkart');
      expect(displayNameFrom('shopkart_creator'), 'Shopkart Creator');
      expect(toCamelCase('shopkart'), 'shopkart');
      expect(toCamelCase('shopkart_creator'), 'shopkartCreator');
    });

    test('ids use com.hybridinteractive by default', () {
      final id = AppIdentity(name: 'shopkart', displayName: 'Shopkart');
      expect(id.androidId, 'com.hybridinteractive.shopkart');
      expect(id.iosId, 'com.hybridinteractive.shopkart');
      expect(
        id.kotlinDir,
        'android/app/src/main/kotlin/com/hybridinteractive/shopkart',
      );
    });

    test('iOS id has no underscores', () {
      final id = AppIdentity(name: 'my_app', displayName: 'My App');
      expect(id.androidId, 'com.hybridinteractive.my_app');
      expect(id.iosId, 'com.hybridinteractive.myApp');
    });
  });

  group('validateRawName', () {
    test('accepts a name as typed', () {
      expect(validateRawName('shopkart'), isNull);
      expect(validateRawName('Food Delivery App'), isNull);
    });

    test('rejects the <your-app-name> placeholder', () {
      expect(validateRawName('<your-app-name>'), contains('real app name'));
      expect(validateRawName('<shopkart>'), isNotNull);
    });

    test('rejects a sentence passed by mistake', () {
      expect(
        validateRawName('please change the example to a placeholder'),
        contains('sentence'),
      );
    });
  });

  group('validation', () {
    test('accepts a normal name', () {
      expect(validateName('shopkart'), isNull);
    });

    test('rejects names that cannot be a package or app id', () {
      expect(validateName(''), isNotNull);
      expect(validateName('1app'), isNotNull);
      expect(validateName('app_template'), isNotNull);
      expect(validateName('class'), isNotNull);
      expect(validateName('new'), isNotNull);
      expect(validateName('dio', takenNames: {'dio'}), isNotNull);
      expect(validateName('a' * (maxNameLength + 1)), contains('longer'));
    });

    test('rejects display names that would break Dart, XML or plist', () {
      expect(validateDisplayName('Shopkart Pro'), isNull);
      expect(validateDisplayName("Mike's"), isNotNull);
      expect(validateDisplayName('A & B'), isNotNull);
      expect(validateDisplayName(r'Price $'), isNotNull);
      expect(validateDisplayName('  '), isNotNull);
    });

    test('org must be a lowercase reverse domain', () {
      expect(validateOrg('com.hybridinteractive'), isNull);
      expect(validateOrg('hybridinteractive'), isNotNull);
      expect(validateOrg('Com.Example'), isNotNull);
      expect(validateOrg('com.new'), isNotNull);
    });

    test('pubspecTopLevelKeys lists dependency names', () {
      const pubspec =
          'name: x\ndependencies:\n  dio: ^5.0.0\n  flutter:\n'
          '    sdk: flutter\n';
      expect(pubspecTopLevelKeys(pubspec), containsAll(['dio', 'flutter']));
    });
  });

  group('replaceIdentity', () {
    final id = AppIdentity(name: 'shopkart', displayName: 'Shopkart');

    test('rewrites every form of the template identity', () {
      expect(
        replaceIdentity("import 'package:app_template/core/x.dart';", id),
        "import 'package:shopkart/core/x.dart';",
      );
      expect(replaceIdentity('name: app_template', id), 'name: shopkart');
      expect(
        replaceIdentity('applicationId = "com.example.app_template"', id),
        'applicationId = "com.hybridinteractive.shopkart"',
      );
      expect(
        replaceIdentity('package com.example.app_template', id),
        'package com.hybridinteractive.shopkart',
      );
      expect(
        replaceIdentity('ID = com.example.appTemplate.RunnerTests;', id),
        'ID = com.hybridinteractive.shopkart.RunnerTests;',
      );
      expect(
        replaceIdentity('android:label="app_template"', id),
        'android:label="Shopkart"',
      );
      expect(
        replaceIdentity("appName = 'App Template';", id),
        "appName = 'Shopkart';",
      );
    });

    test('leaves unrelated words alone', () {
      const text = 'my_app_template_android and appTemplates';
      expect(replaceIdentity(text, id), text);
    });
  });

  group('stripGeneratorReferences', () {
    test('drops the marked block, tree entry and new-app lines', () {
      const markdown =
          'Intro\n'
          '<!-- new-app:start -->\n## New app\nRun /new-app.\n'
          '<!-- new-app:end -->\n'
          'tool/  # check_architecture.dart, new_app.dart\n'
          '- New app: `.claude/skills/new-app/SKILL.md`\n'
          'Outro\n';
      expect(
        stripGeneratorReferences(markdown),
        'Intro\ntool/  # check_architecture.dart\nOutro\n',
      );
    });
  });

  group('planChanges + applyChanges', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('new_app_test_');
      void write(String path, String content) => File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync(content);

      write('pubspec.yaml', 'name: app_template\n');
      write('lib/main.dart', "import 'package:app_template/app/app.dart';\n");
      write(
        'android/app/src/main/kotlin/com/example/app_template/MainActivity.kt',
        'package com.example.app_template\n',
      );
      write('CLAUDE.md', '- New app: `/new-app <name>`\n- Keep me\n');
      write('tool/new_app.dart', '// generator\n');
      write('test/tool/new_app_test.dart', '// generator test\n');
      write('.claude/skills/new-app/SKILL.md', 'skill\n');
      write('.env.example', 'BASE_URL=x\n');
      write('build/app_template.txt', 'app_template\n');
    });

    tearDown(() => root.deleteSync(recursive: true));

    test('renames, moves Kotlin, removes the generator, creates .env', () {
      final id = AppIdentity(name: 'shopkart', displayName: 'Shopkart');
      applyChanges(root, planChanges(root, id));

      String read(String path) => File('${root.path}/$path').readAsStringSync();
      bool exists(String path) =>
          FileSystemEntity.typeSync('${root.path}/$path') !=
          FileSystemEntityType.notFound;

      expect(read('pubspec.yaml'), 'name: shopkart\n');
      expect(read('lib/main.dart'), contains('package:shopkart/'));
      expect(
        read(
          'android/app/src/main/kotlin/com/hybridinteractive/shopkart/'
          'MainActivity.kt',
        ),
        'package com.hybridinteractive.shopkart\n',
      );
      expect(exists('android/app/src/main/kotlin/com/example'), isFalse);
      expect(read('CLAUDE.md'), '- Keep me\n');
      expect(exists('tool/new_app.dart'), isFalse);
      expect(exists('test/tool'), isFalse);
      expect(exists('.claude/skills/new-app'), isFalse);
      expect(read('.env'), 'BASE_URL=x\n');
      // Build output is never touched.
      expect(read('build/app_template.txt'), 'app_template\n');
    });
  });
}
