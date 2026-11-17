import 'package:material_ui/material_ui.dart';

import '../theme/app_dimensions.dart';
import 'app_button.dart';

class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? message;
  final Widget? icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ??
                Icon(
                  Icons.inbox_outlined,
                  size: AppDimensions.iconLg * 2,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              AppButton(text: actionText!, onPressed: onAction, width: 160),
            ],
          ],
        ),
      ),
    );
  }
}
