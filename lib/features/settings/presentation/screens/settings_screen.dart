import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../backup/presentation/providers/backup_provider.dart';
import '../../../backup/presentation/widgets/import_dialog.dart';

/// Screen for managing application settings, locale, theme, and backups.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final backupState = ref.watch(backupNotifierProvider);

    // Listen to backup states for notifications
    ref.listen<BackupState>(backupNotifierProvider, (previous, next) {
      if (next is BackupExportSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next is BackupImportSuccess) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.importSummaryTitle),
              ],
            ),
            content: Text(
              l10n.importSummaryMessage(next.imported, next.skipped),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (next is BackupError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final isLoading = backupState is BackupLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Section 1: Appearance & Theme
              _buildSectionHeader(context, l10n.appearance),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_medium),
                      title: Text(l10n.theme),
                      subtitle: Text(_getThemeName(currentThemeMode, l10n)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showThemeDialog(context, ref, currentThemeMode, l10n),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Language & Localization
              _buildSectionHeader(context, l10n.language),
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(l10n.english),
                      subtitle: const Text('English (LTR)'),
                      value: 'en',
                      groupValue: currentLocale.languageCode,
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(localeProvider.notifier).setLocale(Locale(val));
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: Text(l10n.persian),
                      subtitle: const Text('فارسی (RTL)'),
                      value: 'fa',
                      groupValue: currentLocale.languageCode,
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(localeProvider.notifier).setLocale(Locale(val));
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Backup & Restore
              _buildSectionHeader(context, l10n.backupAndRestore),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.file_upload_outlined, color: colorScheme.primary),
                      title: Text(l10n.exportBackup),
                      subtitle: Text(l10n.exportSubtitle),
                      trailing: const Icon(Icons.share, size: 20),
                      onTap: isLoading
                          ? null
                          : () {
                              _showExportOptions(context, ref, l10n);
                            },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.file_download_outlined, color: colorScheme.secondary),
                      title: Text(l10n.importBackup),
                      subtitle: Text(l10n.importSubtitle),
                      trailing: const Icon(Icons.folder_open, size: 20),
                      onTap: isLoading
                          ? null
                          : () async {
                              final notifier = ref.read(backupNotifierProvider.notifier);
                              final books = await notifier.pickAndValidateBackup();
                              if (books != null && books.isNotEmpty && context.mounted) {
                                final strategy = await ImportDialog.show(context, books.length);
                                if (strategy != null) {
                                  await notifier.executeImport(
                                    books: books,
                                    replaceExisting: strategy == ImportStrategy.replace,
                                  );
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Offline App badge
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '100% Offline • No Account Required',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black38,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          (backupState as BackupLoading).message,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share via Android Share Sheet'),
              subtitle: const Text('Nearby Share, Bluetooth, messaging apps'),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(backupNotifierProvider.notifier).exportAndShare();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save_alt_outlined),
              title: const Text('Save to Device Storage'),
              subtitle: const Text('Downloads or Documents folder'),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(backupNotifierProvider.notifier).exportToSavedFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemTheme;
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemTheme),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                  Navigator.of(ctx).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightTheme),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                  Navigator.of(ctx).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkTheme),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
