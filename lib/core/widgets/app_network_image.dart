import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// The one way to show an image from a URL. Use it instead of `Image.network`
/// (the architecture check rejects that everywhere else).
///
/// - Cached on disk, so a list scrolled back up does not download again.
/// - Decoded at the size it is shown, not the file's full size. A 4000 px
///   photo shown in a 100 px avatar would otherwise sit in memory at
///   4000 px; on a long list that is what runs a phone out of memory.
/// - A null or empty [url] shows [errorWidget] without making a request.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Shown while loading. Defaults to a plain surface-coloured box.
  final Widget? placeholder;

  /// Shown when [url] is empty or the download fails. Defaults to a
  /// broken-image icon.
  final Widget? errorWidget;

  /// Describes the image for screen readers. Leave null for decorative images.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Only measure the layout when no size was given; LayoutBuilder costs a
    // little on every frame, so skip it when it would tell us nothing new.
    final Widget image = width != null || height != null
        ? _buildImage(context, width, height)
        : LayoutBuilder(
            builder: (context, constraints) => _buildImage(
              context,
              constraints.hasBoundedWidth ? constraints.maxWidth : null,
              constraints.hasBoundedHeight ? constraints.maxHeight : null,
            ),
          );

    final clipped = borderRadius == null
        ? image
        : ClipRRect(borderRadius: borderRadius!, child: image);

    if (semanticLabel == null) return clipped;
    return Semantics(label: semanticLabel, image: true, child: clipped);
  }

  Widget _buildImage(
    BuildContext context,
    double? layoutWidth,
    double? layoutHeight,
  ) {
    final source = url;
    if (source == null || source.isEmpty) {
      return errorWidget ?? _AppImageFallback(width: width, height: height);
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // Decode by ONE side only, so the image keeps its aspect ratio. Width is
    // preferred because lists and grids almost always bound it.
    final decodeWidth = _toPixels(layoutWidth, pixelRatio);
    final decodeHeight = decodeWidth == null
        ? _toPixels(layoutHeight, pixelRatio)
        : null;

    return CachedNetworkImage(
      imageUrl: source,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: decodeWidth,
      memCacheHeight: decodeHeight,
      placeholder: (context, _) =>
          placeholder ?? _AppImagePlaceholder(width: width, height: height),
      errorWidget: (context, _, _) =>
          errorWidget ?? _AppImageFallback(width: width, height: height),
    );
  }

  static int? _toPixels(double? logical, double pixelRatio) {
    if (logical == null || !logical.isFinite || logical <= 0) return null;
    return (logical * pixelRatio).round();
  }
}

class _AppImagePlaceholder extends StatelessWidget {
  const _AppImagePlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _AppImageFallback extends StatelessWidget {
  const _AppImageFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: AppDimensions.iconLg,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
