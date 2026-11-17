import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:material_ui/material_ui.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconLg,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
