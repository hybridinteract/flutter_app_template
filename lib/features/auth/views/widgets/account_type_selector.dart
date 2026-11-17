import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';

import '../../models/account_type.dart';

/// Creator / Brand choice at signup. It decides the account's role and what
/// the "organisation" field means, and it cannot be changed later.
class AccountTypeSelector extends StatelessWidget {
  const AccountTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final AccountType selected;
  final ValueChanged<AccountType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.authAccountTypeLabel, style: context.textTheme.labelLarge),
        const SizedBox(height: AppDimensions.spacingSm),
        SegmentedButton<AccountType>(
          segments: [
            ButtonSegment(
              value: AccountType.influencer,
              label: Text(l10n.authAccountTypeCreator),
              icon: const Icon(Icons.person_outline),
            ),
            ButtonSegment(
              value: AccountType.organization,
              label: Text(l10n.authAccountTypeBrand),
              icon: const Icon(Icons.storefront_outlined),
            ),
          ],
          selected: {selected},
          onSelectionChanged: enabled
              ? (selection) => onChanged(selection.first)
              : null,
        ),
      ],
    );
  }
}
