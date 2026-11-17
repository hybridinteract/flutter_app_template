import 'package:material_ui/material_ui.dart';

import '../theme/app_dimensions.dart';
import 'app_loader.dart';

enum AppButtonVariant { primary, secondary, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final double? width;
  final double height;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = isLoading
        ? SizedBox(
            height: AppDimensions.iconSm,
            width: AppDimensions.iconSm,
            child: AppLoader(
              color: variant == AppButtonVariant.primary
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              strokeWidth: 2.0,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppDimensions.spacingSm),
              ],
              Text(text),
            ],
          );

    final buttonStyle = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        minimumSize: Size(width ?? double.infinity, height),
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        minimumSize: Size(width ?? double.infinity, height),
      ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
        minimumSize: Size(width ?? double.infinity, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    };

    return SizedBox(
      width: width,
      height: height,
      child: variant == AppButtonVariant.outline
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: content,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: content,
            ),
    );
  }
}
