import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/book_providers.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/sort_filter_bottom_sheet.dart';
import 'add_edit_book_screen.dart';
import 'book_details_screen.dart';

/// Primary screen displaying searchable and sortable list of books.
class BookListScreen extends ConsumerWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final booksAsync = ref.watch(bookListNotifierProvider);
    final totalCountAsync = ref.watch(totalBooksCountProvider);
    final currentSort = ref.watch(sortOptionProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            totalCountAsync.when(
              data: (count) => Text(
                l10n.totalBooks(count),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortBy,
            onPressed: () {
              SortFilterBottomSheet.show(
                context,
                currentOption: currentSort,
                onSelectOption: (newOption) {
                  ref.read(sortOptionProvider.notifier).setSortOption(newOption);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          SearchBarWidget(
            initialQuery: searchQuery,
            onChanged: (val) {
              ref.read(searchQueryProvider.notifier).state = val;
            },
            onClear: () {
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),

          // Reactive Book Collection
          Expanded(
            child: booksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '${l10n.errorOccurred}: $err',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (books) {
                if (books.isEmpty) {
                  final isSearching = searchQuery.trim().isNotEmpty;
                  if (isSearching) {
                    return EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: l10n.noResultsTitle,
                      subtitle: l10n.noResultsSubtitle,
                      actionLabel: l10n.clearSearch,
                      onActionPressed: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    );
                  }
                  return EmptyStateView(
                    icon: Icons.auto_stories_outlined,
                    title: l10n.emptyLibraryTitle,
                    subtitle: l10n.emptyLibrarySubtitle,
                    actionLabel: l10n.addFirstBook,
                    onActionPressed: () => _navigateToAdd(context),
                  );
                }

                return ListView.builder(
                  itemCount: books.length,
                  padding: const EdgeInsets.only(top: 4, bottom: 88),
                  itemBuilder: (ctx, index) {
                    final book = books[index];
                    return BookCard(
                      book: book,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookDetailsScreen(bookId: book.id!),
                          ),
                        );
                      },
                      onIncrementQuantity: () {
                        ref
                            .read(bookListNotifierProvider.notifier)
                            .incrementQuantity(book);
                      },
                      onDecrementQuantity: () {
                        ref
                            .read(bookListNotifierProvider.notifier)
                            .decrementQuantity(book);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addBook),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditBookScreen(),
      ),
    );
  }
}
