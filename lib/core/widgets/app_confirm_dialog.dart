import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';

/// A yes/no question before an action the user may regret (delete, sign out,
/// discard changes). Open it with [AppConfirmDialog.show]:
///
/// ```dart
/// final confirmed = await AppConfirmDialog.show(
///   context,
///   title: l10n.productDeleteTitle,
///   message: l10n.productDeleteMessage,
///   confirmText: l10n.productDeleteConfirm,
///   isDestructive: true,
/// );
/// if (confirmed && context.mounted) bloc.add(ProductDeleted(id));
/// ```
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
  });

  final String title;
  final String? message;

  /// Defaults to the localized "Confirm".
  final String? confirmText;

  /// Defaults to the localized "Cancel".
  final String? cancelText;

  /// Colours the confirm button as an error, for actions that delete or lose
  /// data.
  final bool isDestructive;

  /// Shows the dialog and resolves to true only when the user confirms.
  /// Tapping outside, back, or Cancel all resolve to false.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final message = this.message;

    return AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          // Dialogs are pageless routes; popping one is not app navigation,
          // so Navigator is correct here rather than go_router.
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: colorScheme.error)
              : null,
          child: Text(confirmText ?? l10n.commonConfirm),
        ),
      ],
    );
  }
}
