import 'package:app_template/core/utils/asset_licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(LicenseRegistry.reset);

  group('registerAssetLicenses', () {
    test('adds one license entry per file, read from the bundle', () async {
      final bundle = FakeAssetBundle({
        'assets/fonts/OFL.txt': 'SIL Open Font License\n\nVersion 1.1',
      });

      registerAssetLicenses(
        bundle: bundle,
        licenses: const {'AppFont': 'assets/fonts/OFL.txt'},
      );

      final entries = await LicenseRegistry.licenses.toList();
      expect(entries, hasLength(1));
      expect(entries.single.packages, ['AppFont']);
      expect(
        entries.single.paragraphs.map((p) => p.text),
        containsAllInOrder(['SIL Open Font License', 'Version 1.1']),
      );
    });

    test('reads the file only when the licenses are requested', () async {
      // A missing file would throw on read; registering must not touch it.
      registerAssetLicenses(
        bundle: FakeAssetBundle(const {}),
        licenses: const {'AppFont': 'assets/fonts/missing.txt'},
      );

      await expectLater(LicenseRegistry.licenses.toList(), throwsA(anything));
    });
  });
}
