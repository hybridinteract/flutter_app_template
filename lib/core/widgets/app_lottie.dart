import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

/// Plays a bundled Lottie animation (an `AppAssets` path under
/// `assets/animations/`). Use it for every Lottie file instead of calling
/// `Lottie.asset` directly.
///
/// - Sits in its own `RepaintBoundary`, so the animation repaints every frame
///   without repainting the screen around it.
/// - Loops by default; set [repeat] to false to play once and stop on the
///   last frame.
/// - Without a [semanticLabel] the animation is treated as decorative and
///   hidden from screen readers.
class AppLottie extends StatelessWidget {
  const AppLottie(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  /// An `AppAssets` constant, never an inline string.
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;

  /// Describes the animation for screen readers. Leave null for decorative
  /// animations.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final animation = RepaintBoundary(
      child: Lottie.asset(
        assetPath,
        width: width,
        height: height,
        repeat: repeat,
        fit: fit,
        // The RepaintBoundary above replaces Lottie's own, so there is one
        // layer, not two.
        addRepaintBoundary: false,
      ),
    );

    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: animation);
    return Semantics(label: label, image: true, child: animation);
  }
}
