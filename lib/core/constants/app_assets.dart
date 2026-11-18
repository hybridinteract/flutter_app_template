/// Every bundled asset path. Code refers to assets only through these
/// constants, never as inline strings.
///
/// Folders under `assets/` (each is listed under `assets:` in pubspec.yaml):
/// - `images/`: raster images (PNG, JPG, WebP). Put the 1x file in `images/`
///   and the same file name in `images/2.0x/` and `images/3.0x/`; Flutter
///   picks the one that matches the screen. Show with `Image.asset`.
/// - `brand/`: app logo and brand marks. Show with `Image.asset`, or `AppSvg`
///   for an SVG.
/// - `icons/`: custom raster icons that are not in the Material set. Show with
///   `Image.asset`.
/// - `svg/`: vector icons and illustrations. Show with `AppSvg`.
/// - `animations/`: Lottie animations (`.json`). Show with `AppLottie`.
/// - `fonts/`: font files, declared under `fonts:` in pubspec.yaml and used
///   through `AppTextStyles.fontFamily`, so they get no constant here. Their
///   license files go in [licenses].
///
/// Add a constant here for every new file. A new subfolder must also be listed
/// under `assets:` in pubspec.yaml.
abstract final class AppAssets {
  // images/

  // brand/

  // icons/

  // svg/

  // animations/

  // fonts/: only their license files, below (the fonts are in pubspec.yaml)

  /// Licenses shown on the licenses page (`showLicensePage`): display name to
  /// license file path, e.g. `'AppFont': 'assets/fonts/OFL.txt'`. Fonts under
  /// the SIL Open Font License must ship with their license; list the file
  /// under `assets:` in pubspec.yaml too. Registered at startup by
  /// `registerAssetLicenses`.
  static const Map<String, String> licenses = {};
}
