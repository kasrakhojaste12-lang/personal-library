import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

enum ImportStrategy {
  merge,
  replace,
}

/// Dialog asking the user to choose between Merging or Replacing the library on import.
class ImportDialog extends StatelessWidget {
  final int bookCount;

  const ImportDialog({
    super.key,
    required this.bookCount,
  });

  static Future<ImportStrategy?> show(BuildContext context, int count) {
    return showDialog<ImportStrategy>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ImportDialog(bookCount: count),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_download_outlined, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.importDialogTitle)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.importDialogDescription(bookCount),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Option 1: Merge
            InkWell(
              onTap: () => Navigator.of(context).pop(ImportStrategy.merge),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.call_merge, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.mergeOptionTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.mergeOptionSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Option 2: Replace
            InkWell(
              onTap: () => Navigator.of(context).pop(ImportStrategy.replace),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.error.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.errorContainer.withOpacity(0.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.replaceOptionTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.replaceOptionSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
