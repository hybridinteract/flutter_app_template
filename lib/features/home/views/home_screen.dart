import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/routes/route_names.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:app_template/core/widgets/app_button.dart';
import 'package:app_template/features/auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.homeLogout,
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final userName = state is AuthSuccess
                ? state.user.name
                : l10n.homeDefaultUserName;
            final userEmail = state is AuthSuccess ? state.user.email : '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: AppDimensions.elevationNone,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.spacingLg,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.homeGreeting(userName),
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    if (userEmail.isNotEmpty) ...[
                                      const SizedBox(
                                        height: AppDimensions.spacingXxs,
                                      ),
                                      Text(
                                        userEmail,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                      Text(
                        l10n.homeFeatures,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      Card(
                        elevation: AppDimensions.elevationLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.book_online_outlined),
                          title: Text(l10n.homeBookingsTitle),
                          subtitle: Text(l10n.homeBookingsSubtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(RouteNames.bookings),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      Card(
                        elevation: AppDimensions.elevationLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(l10n.homeProfileTitle),
                          subtitle: Text(l10n.homeProfileSubtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(RouteNames.profile),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                      AppButton(
                        text: l10n.homeSignOut,
                        variant: AppButtonVariant.outline,
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          context.read<AuthBloc>().add(const LogoutRequested());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
