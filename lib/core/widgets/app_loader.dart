import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.color,
    this.strokeWidth = 3.0,
    this.size,
    this.message,
  });

  final Color? color;
  final double strokeWidth;
  final double? size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      ),
    );

    if (message == null) {
      return Center(child: indicator);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
