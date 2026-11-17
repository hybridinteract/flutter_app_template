import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:app_template/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state is AuthSuccess ? state.user : null;

                return ListView(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: context.colorScheme.primary,
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 32,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Card(
                      elevation: AppDimensions.elevationLow,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(l10n.profileName),
                            subtitle: Text(user?.name ?? l10n.commonNotSet),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: Text(l10n.profileEmail),
                            subtitle: Text(user?.email ?? l10n.commonNotSet),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.badge_outlined),
                            title: Text(l10n.profileRole),
                            subtitle: Text(
                              user?.role.toUpperCase() ??
                                  l10n.profileDefaultRole,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
