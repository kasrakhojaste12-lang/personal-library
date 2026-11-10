import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/sort_option.dart';

/// Bottom sheet displaying selectable sorting options.
class SortFilterBottomSheet extends StatelessWidget {
  final BookSortOption currentOption;
  final ValueChanged<BookSortOption> onSelectOption;

  const SortFilterBottomSheet({
    super.key,
    required this.currentOption,
    required this.onSelectOption,
  });

  static Future<void> show(
    BuildContext context, {
    required BookSortOption currentOption,
    required ValueChanged<BookSortOption> onSelectOption,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SortFilterBottomSheet(
        currentOption: currentOption,
        onSelectOption: onSelectOption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                l10n.sortBy,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            _buildSortTile(
              context,
              option: BookSortOption.dateAddedDesc,
              title: l10n.sortDateDesc,
              icon: Icons.calendar_today,
            ),
            _buildSortTile(
              context,
              option: BookSortOption.dateAddedAsc,
              title: l10n.sortDateAsc,
              icon: Icons.history,
            ),
            _buildSortTile(
              context,
              option: BookSortOption.titleAsc,
              title: l10n.sortTitleAsc,
              icon: Icons.sort_by_alpha,
            ),
            _buildSortTile(
              context,
              option: BookSortOption.titleDesc,
              title: l10n.sortTitleDesc,
              icon: Icons.sort_by_alpha,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTile(
    BuildContext context, {
    required BookSortOption option,
    required String title,
    required IconData icon,
  }) {
    final isSelected = currentOption == option;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.of(context).pop();
        onSelectOption(option);
      },
    );
  }
}
