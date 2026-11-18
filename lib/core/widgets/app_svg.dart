import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Shows a bundled SVG (an `AppAssets` path, usually under `assets/svg/` or
/// `assets/brand/`). Use it for every SVG instead of calling `SvgPicture`
/// directly.
///
/// - [color] tints the whole SVG with one colour (e.g. a theme colour for a
///   monochrome icon). Leave it null to keep the SVG's own colours.
/// - Without a [semanticLabel] the SVG is treated as decorative and hidden
///   from screen readers.
class AppSvg extends StatelessWidget {
  const AppSvg(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  /// An `AppAssets` constant, never an inline string.
  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  /// Describes the image for screen readers. Leave null for decorative images.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint = color;
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
