// Turns a fresh clone of this template into a new app, like `flutter create`
// with this template's architecture. Normally run by the /new-app skill
// (.claude/skills/new-app/SKILL.md), which also regenerates code, runs the
// quality checks and starts a fresh git history.
//
// Usage (from the project root):
//   dart run tool/new_app.dart <your-app-name> [--display-name "Name"] [--org com.x] [--dry-run]
//
//   <your-app-name> App name; normalized to a snake_case Dart package
//                   ("Shop App" -> shop_app, "MyApp" -> my_app).
//                   At most 3 words / 30 characters, no < >.
//   --display-name  Launcher / window name. Default: from the name ("Shop App").
//   --org           Reverse domain. Default: com.hybridinteractive, giving
//                   com.hybridinteractive.<your-app-name> on Android and iOS.
//   --dry-run       Print every change without writing anything.
//
// What it changes: the Dart package (pubspec + every package: import), the
// Android applicationId / namespace / label and Kotlin folder, the iOS bundle
// ids / display name, AppConstants.appName, docs, rules and skills. It then
// removes itself (this script, its test, the new-app skill and prompt) because
// a generated app does not ship the generator. It refuses to run twice.
import 'dart:io';

const templateName = 'app_template';
const templateDisplayName = 'App Template';
const templateCamelName = 'appTemplate';
const templateAndroidId = 'com.example.app_template';
const templateIosId = 'com.example.appTemplate';
const defaultOrg = 'com.hybridinteractive';

const _kotlinRoot = 'android/app/src/main/kotlin';

/// An app name longer than this is almost certainly a sentence, not a name.
const maxNameWords = 3;
const maxNameLength = 30;

/// Files and folders that belong to the generator, not to the generated app.
const generatorPaths = [
  'tool/new_app.dart',
  'test/tool',
  '.claude/skills/new-app',
  '.agent/skills/new-app',
  'docs/NEW_APP_PROMPT.md',
];

/// Build output, caches, version control and IDE state are never edited.
const _skippedDirs = {
  '.git',
  '.dart_tool',
  '.gradle',
  '.idea',
  'build',
  'coverage',
  'ephemeral',
  'Pods',
};

const _textExtensions = {
  '.arb',
  '.dart',
  '.gradle',
  '.html',
  '.json',
  '.kt',
  '.kts',
  '.md',
  '.pbxproj',
  '.plist',
  '.properties',
  '.sh',
  '.swift',
  '.txt',
  '.xcconfig',
  '.xml',
  '.yaml',
  '.yml',
};

/// Keywords that cannot be a Dart package name or a Java/Kotlin package
/// segment (the Android applicationId is also the Kotlin package).
// dart format off
const _reservedWords = {
  'abstract', 'as', 'assert', 'async', 'await', 'base', 'boolean', 'break',
  'byte', 'case', 'catch', 'char', 'class', 'const', 'continue', 'covariant',
  'default', 'deferred', 'do', 'double', 'dynamic', 'else', 'enum', 'export',
  'extends', 'extension', 'external', 'factory', 'false', 'final', 'finally',
  'float', 'for', 'fun', 'function', 'get', 'goto', 'hide', 'if', 'implements',
  'import', 'in', 'instanceof', 'int', 'interface', 'is', 'late', 'library',
  'long', 'mixin', 'native', 'new', 'null', 'object', 'of', 'on', 'operator',
  'package', 'part', 'private', 'protected', 'public', 'required', 'rethrow',
  'return', 'sealed', 'set', 'short', 'show', 'static', 'strictfp', 'super',
  'switch', 'sync', 'synchronized', 'this', 'throw', 'throws', 'transient',
  'true', 'try', 'typealias', 'typedef', 'val', 'var', 'void', 'volatile',
  'when', 'while', 'with', 'yield',
};
// dart format on

/// The names and ids derived from the app name.
class AppIdentity {
  AppIdentity({required this.name, required this.displayName, String? org})
    : org = org ?? defaultOrg;

  /// snake_case Dart package name, e.g. `shop_app`.
  final String name;

  /// Human-readable name, e.g. `Shop App`.
  final String displayName;

  /// Reverse domain, e.g. `com.hybridinteractive`.
  final String org;

  /// Android applicationId, namespace and Kotlin package.
  String get androidId => '$org.$name';

  /// iOS bundle id. iOS does not allow underscores, so the name is camelCased.
  String get iosId => '$org.${toCamelCase(name)}';

  String get kotlinDir => '$_kotlinRoot/${androidId.replaceAll('.', '/')}';
}

/// "Shop App" / "shop-app" / "ShopApp" -> shop_app.
String normalizeName(String input) => input
    .trim()
    .replaceAllMapped(RegExp('([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
    .toLowerCase()
    .replaceAll(RegExp(r'[\s\-.]+'), '_')
    .replaceAll(RegExp('[^a-z0-9_]'), '')
    .replaceAll(RegExp('_+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

/// my_app -> myApp.
String toCamelCase(String snake) {
  final parts = snake.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return snake;
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

/// my_app -> My App.
String displayNameFrom(String snake) => snake
    .split('_')
    .where((p) => p.isNotEmpty)
    .map((p) => p[0].toUpperCase() + p.substring(1))
    .join(' ');

/// Checks the name exactly as typed, before [normalizeName]. Catches a
/// placeholder (`<your-app-name>`) or a sentence passed by mistake, which
/// would otherwise normalize into a valid but unwanted package name.
String? validateRawName(String input) {
  final trimmed = input.trim();
  if (trimmed.contains('<') || trimmed.contains('>')) {
    return 'Replace <your-app-name> with your real app name, '
        'e.g. /new-app shop_app.';
  }
  final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.length > maxNameWords) {
    return '"$trimmed" looks like a sentence, not an app name '
        '(max $maxNameWords words). Example: /new-app shop_app.';
  }
  return null;
}

/// Returns why [name] cannot be used, or null when it is valid.
/// [takenNames] are packages the app already depends on.
String? validateName(String name, {Set<String> takenNames = const {}}) {
  if (name.isEmpty) return 'The app name is empty.';
  if (name.length > maxNameLength) {
    return '"$name" is longer than $maxNameLength characters.';
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    return '"$name" must start with a letter and use only a-z, 0-9 and _.';
  }
  if (name == templateName) return '"$name" is the template\'s own name.';
  if (_reservedWords.contains(name)) {
    return '"$name" is a reserved word in Dart, Java or Kotlin.';
  }
  if (takenNames.contains(name)) {
    return '"$name" is already a dependency of this app; pick another name.';
  }
  return null;
}

/// Returns why [displayName] cannot be used, or null when it is valid.
/// Quotes, `$`, `\` and XML characters would break the files it is written to.
String? validateDisplayName(String displayName) {
  if (displayName.trim().isEmpty) return 'The display name is empty.';
  if (RegExp(r'''["'$\\<>&\n]''').hasMatch(displayName)) {
    return 'The display name cannot contain quotes, \$, \\, <, > or &.';
  }
  return null;
}

/// Returns why [org] cannot be used, or null when it is valid.
String? validateOrg(String org) {
  if (!RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9_]*)+$').hasMatch(org)) {
    return '"$org" must be a lowercase reverse domain, e.g. com.company.';
  }
  final reserved = org.split('.').where(_reservedWords.contains);
  if (reserved.isNotEmpty) {
    return '"$org" contains the reserved word "${reserved.first}".';
  }
  return null;
}

/// Rewrites every form of the template's identity in one file's [content].
String replaceIdentity(String content, AppIdentity id) => content
    .replaceAll(templateAndroidId, id.androidId)
    .replaceAll(templateIosId, id.iosId)
    // The Android launcher label is the display name, not the package name.
    .replaceAll(
      'android:label="$templateName"',
      'android:label="${id.displayName}"',
    )
    .replaceAll(RegExp('\\b$templateName\\b'), id.name)
    .replaceAll(templateDisplayName, id.displayName)
    .replaceAll(RegExp('\\b$templateCamelName\\b'), toCamelCase(id.name));

/// Removes the generator's own documentation from a markdown file: the block
/// between `<!-- new-app:start -->` and `<!-- new-app:end -->`, the
/// `new_app.dart` entry in folder trees, and lines that point at the
/// new-app skill or prompt.
String stripGeneratorReferences(String content) {
  final withoutBlocks = content.replaceAll(
    RegExp(
      r'[ \t]*<!-- new-app:start -->.*?<!-- new-app:end -->[ \t]*\r?\n?',
      dotAll: true,
    ),
    '',
  );
  return withoutBlocks
      .replaceAll(', new_app.dart', '')
      .split('\n')
      .where(
        (line) =>
            !line.contains('new-app') &&
            !line.contains('NEW_APP_PROMPT') &&
            !line.contains('new_app.dart'),
      )
      .join('\n');
}

/// Package names the app already uses (dependencies, dev_dependencies...).
Set<String> pubspecTopLevelKeys(String pubspec) => {
  for (final match in RegExp(
    r'^  ([a-z_][a-z0-9_]*):',
    multiLine: true,
  ).allMatches(pubspec))
    match.group(1)!,
};

/// One pending change to the project.
sealed class Change {
  const Change(this.path);
  final String path;
}

class EditFile extends Change {
  const EditFile(super.path, this.content);
  final String content;
}

class MoveFile extends Change {
  const MoveFile(super.path, this.to);
  final String to;
}

class DeletePath extends Change {
  const DeletePath(super.path);
}

class CreateFile extends Change {
  const CreateFile(super.path, this.content);
  final String content;
}

/// Works out every change needed under [root] without writing anything.
List<Change> planChanges(Directory root, AppIdentity id) {
  final changes = <Change>[];
  final generator = generatorPaths.map(_normalize).toList();
  bool isGenerator(String path) =>
      generator.any((g) => path == g || path.startsWith('$g/'));

  for (final file in _textFiles(root)) {
    final path = _relative(root, file);
    if (isGenerator(path)) continue;
    final original = file.readAsStringSync();
    var updated = replaceIdentity(original, id);
    if (path.endsWith('.md')) updated = stripGeneratorReferences(updated);
    if (updated != original) changes.add(EditFile(path, updated));
  }

  final oldKotlin = Directory(
    '${root.path}/$_kotlinRoot/${templateAndroidId.replaceAll('.', '/')}',
  );
  if (oldKotlin.existsSync()) {
    for (final file in oldKotlin.listSync(recursive: true).whereType<File>()) {
      final inner = file.path
          .replaceAll(r'\', '/')
          .substring(oldKotlin.path.replaceAll(r'\', '/').length + 1);
      changes.add(MoveFile(_relative(root, file), '${id.kotlinDir}/$inner'));
    }
  }

  for (final path in generatorPaths) {
    final entity = FileSystemEntity.typeSync('${root.path}/$path');
    if (entity != FileSystemEntityType.notFound) changes.add(DeletePath(path));
  }

  final env = File('${root.path}/.env');
  final envExample = File('${root.path}/.env.example');
  if (!env.existsSync() && envExample.existsSync()) {
    changes.add(CreateFile('.env', envExample.readAsStringSync()));
  }
  return changes;
}

/// Writes [changes] under [root]. Edits happen before moves, so a moved
/// file keeps its rewritten content.
void applyChanges(Directory root, List<Change> changes) {
  for (final change in changes) {
    final target = File('${root.path}/${change.path}');
    switch (change) {
      case EditFile(:final content):
        target.writeAsStringSync(content);
      case CreateFile(:final content):
        target.writeAsStringSync(content);
      case MoveFile() || DeletePath():
        break;
    }
  }
  for (final change in changes.whereType<MoveFile>()) {
    final to = File('${root.path}/${change.to}')
      ..parent.createSync(recursive: true);
    File('${root.path}/${change.path}').renameSync(to.path);
  }
  _deleteEmptyDirs(Directory('${root.path}/$_kotlinRoot'));
  for (final change in changes.whereType<DeletePath>()) {
    final path = '${root.path}/${change.path}';
    if (FileSystemEntity.isDirectorySync(path)) {
      Directory(path).deleteSync(recursive: true);
    } else {
      File(path).deleteSync();
    }
  }
}

void main(List<String> args) {
  final options = _parseArgs(args);
  final root = Directory.current;
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    _fail('Run from the project root (pubspec.yaml not found).');
  }

  final pubspecText = pubspec.readAsStringSync();
  final currentName = RegExp(
    r'^name:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspecText)?.group(1);
  if (currentName != templateName) {
    _fail(
      'This project is already "$currentName", not the template '
      '($templateName). /new-app runs once, on a fresh clone.',
    );
  }

  final rawError = validateRawName(options.name);
  if (rawError != null) _fail(rawError);
  final name = normalizeName(options.name);
  final displayName = options.displayName ?? displayNameFrom(name);
  final org = options.org ?? defaultOrg;
  final error =
      validateName(name, takenNames: pubspecTopLevelKeys(pubspecText)) ??
      validateDisplayName(displayName) ??
      validateOrg(org);
  if (error != null) _fail(error);

  final id = AppIdentity(name: name, displayName: displayName, org: org);
  final changes = planChanges(root, id);

  stdout
    ..writeln('Package       $templateName -> ${id.name}')
    ..writeln('Display name  $templateDisplayName -> ${id.displayName}')
    ..writeln('Android id    $templateAndroidId -> ${id.androidId}')
    ..writeln('iOS bundle id $templateIosId -> ${id.iosId}')
    ..writeln();
  for (final change in changes) {
    stdout.writeln(switch (change) {
      EditFile() => 'edit    ${change.path}',
      MoveFile(:final to) => 'move    ${change.path} -> $to',
      DeletePath() => 'delete  ${change.path}',
      CreateFile() => 'create  ${change.path}',
    });
  }
  stdout.writeln();

  if (options.dryRun) {
    stdout.writeln('Dry run: ${changes.length} changes, nothing written.');
    return;
  }
  applyChanges(root, changes);
  stdout.writeln(
    'Done: ${changes.length} changes. Next: flutter clean, '
    'flutter pub get, build_runner, gen-l10n, sync_agent_config, '
    'dart fix --apply --code=directives_ordering, dart format.',
  );
}

typedef _Options = ({
  String name,
  String? displayName,
  String? org,
  bool dryRun,
});

_Options _parseArgs(List<String> args) {
  String? name;
  String? displayName;
  String? org;
  var dryRun = false;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--dry-run':
        dryRun = true;
      case '--display-name' || '--org':
        if (i + 1 >= args.length) _fail('$arg needs a value.');
        if (arg == '--org') {
          org = args[++i];
        } else {
          displayName = args[++i];
        }
      default:
        if (arg.startsWith('--')) _fail('Unknown option $arg.');
        name = name == null ? arg : '$name $arg';
    }
  }
  if (name == null) {
    _fail(
      'Usage: dart run tool/new_app.dart <your-app-name> '
      '[--display-name "Name"] [--org com.x] [--dry-run]',
    );
  }
  return (name: name, displayName: displayName, org: org, dryRun: dryRun);
}

Iterable<File> _textFiles(Directory root) sync* {
  for (final entity in root.listSync(followLinks: false)) {
    final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (entity is Directory) {
      if (!_skippedDirs.contains(name)) yield* _textFiles(entity);
    } else if (entity is File) {
      final dot = name.lastIndexOf('.');
      final extension = dot <= 0 ? '' : name.substring(dot);
      if (_textExtensions.contains(extension)) yield entity;
    }
  }
}

void _deleteEmptyDirs(Directory dir) {
  if (!dir.existsSync()) return;
  for (final child in dir.listSync().whereType<Directory>()) {
    _deleteEmptyDirs(child);
  }
  if (dir.listSync().isEmpty) dir.deleteSync();
}

String _relative(Directory root, File file) =>
    _normalize(file.path.substring(root.path.length + 1));

String _normalize(String path) => path.replaceAll(r'\', '/');

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
