import 'package:app_template/core/constants/app_constants.dart';
import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:material_ui/material_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              children: [
                Card(
                  elevation: AppDimensions.elevationLow,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: context.theme.brightness == Brightness.dark,
                        onChanged: (val) {
                          context.showSnackBar(l10n.settingsThemeToggled);
                        },
                        title: Text(l10n.settingsDarkMode),
                        secondary: const Icon(Icons.dark_mode_outlined),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: Text(l10n.settingsLanguage),
                        trailing: Text(l10n.settingsLanguageName),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(l10n.settingsAbout),
                        subtitle: Text(
                          l10n.settingsVersion(AppConstants.appVersion),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
