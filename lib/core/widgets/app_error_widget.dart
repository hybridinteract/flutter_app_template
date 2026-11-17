import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme/app_dimensions.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryText,
    this.icon,
  });

  final String message;

  /// Defaults to the localized "Something went wrong".
  final String? title;
  final VoidCallback? onRetry;

  /// Defaults to the localized "Try Again".
  final String? retryText;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                Icon(
                  Icons.error_outline_rounded,
                  size: AppDimensions.iconLg * 2,
                  color: theme.colorScheme.error,
                ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              title ?? l10n.commonSomethingWentWrong,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              AppButton(
                text: retryText ?? l10n.commonTryAgain,
                onPressed: onRetry,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
