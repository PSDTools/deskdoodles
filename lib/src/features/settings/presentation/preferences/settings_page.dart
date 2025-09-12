/// This library
library;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/settings_service.dart';

/// {@template deskdoodles.features.settings.presentation.preferences.settings_page}
/// Display the various settings that can be customized by the user.
///
/// When a user changes a setting, this updates the [SettingsService] and
/// [Widget]s that watch the [SettingsService] are rebuilt.
/// {@endtemplate}
@RoutePage(deferredLoading: true)
class SettingsPage extends ConsumerWidget {
  /// {@macro deskdoodles.features.settings.presentation.preferences.settings_page}
  ///
  /// Construct a new [SettingsPage] widget.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Glue the `settingsServiceProvider` to the theme selection `DropdownMenu`.
    //
    // When a user selects a theme from the dropdown list, the
    // `settingsServiceProvider` is updated, which rebuilds the `MaterialApp`.
    final settingsService = ref.watch(settingsServiceProvider);
    final themeMode = settingsService.themeMode;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                alignment: Alignment.topLeft,
                child: DropdownMenu(
                  // Read the selected themeMode from the controller
                  initialSelection: themeMode,
                  // Call the updateThemeMode method any time the user selects a theme.
                  onSelected: (theme) async {
                    final newTheme = theme ?? settingsService.themeMode;

                    await ref
                        .read(settingsServiceProvider.notifier)
                        .updateThemeMode(newTheme);
                  },
                  label: const Text('Theme'),
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                      value: ThemeMode.system,
                      label: 'System Theme',
                      leadingIcon: Icon(Icons.brightness_medium),
                    ),
                    DropdownMenuEntry(
                      value: ThemeMode.light,
                      label: 'Light Theme',
                      leadingIcon: Icon(Icons.brightness_5),
                    ),
                    DropdownMenuEntry(
                      value: ThemeMode.dark,
                      label: 'Dark Theme',
                      leadingIcon: Icon(Icons.brightness_3),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                alignment: Alignment.topLeft,
                child: ElevatedButton(
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'DeskDoodles',
                      applicationLegalese:
                          '© PSDTools, licensed under the Universal Permissive License 1.0.',
                    );
                  },
                  child: const Text('About'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
