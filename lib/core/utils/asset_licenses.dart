import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../constants/app_assets.dart';

/// Adds the license of every bundled asset in [AppAssets.licenses] (such as
/// an OFL font) to the app's licenses page (`showLicensePage`). Call it once
/// from `main()`.
///
/// Each file is read only when the licenses page asks for it, so this costs
/// nothing at startup. [bundle] defaults to `rootBundle`; tests pass a fake
/// one, and may pass their own [licenses].
void registerAssetLicenses({
  AssetBundle? bundle,
  Map<String, String> licenses = AppAssets.licenses,
}) {
  for (final MapEntry(key: name, value: path) in licenses.entries) {
    LicenseRegistry.addLicense(() async* {
      final text = await (bundle ?? rootBundle).loadString(path);
      yield LicenseEntryWithLineBreaks([name], text);
    });
  }
}
