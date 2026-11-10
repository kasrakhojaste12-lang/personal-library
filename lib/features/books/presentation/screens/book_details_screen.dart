import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/book.dart';
import '../providers/book_providers.dart';
import '../widgets/quantity_stepper.dart';
import 'add_edit_book_screen.dart';

/// Screen displaying full details of a specific book with management actions.
class BookDetailsScreen extends ConsumerStatefulWidget {
  final int bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  Book? _book;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final repo = ref.read(bookRepositoryProvider);
    final book = await repo.getBookById(widget.bookId);
    if (mounted) {
      setState(() {
        _book = book;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBook() async {
    if (_book == null) return;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBook),
        content: Text(l10n.deleteConfirmation(_book!.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(bookListNotifierProvider.notifier).deleteBook(widget.bookId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookDeleted),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _navigateToEdit() async {
    if (_book == null) return;
    final updated = await Navigator.of(context).push<Book?>(
      MaterialPageRoute(
        builder: (_) => AddEditBookScreen(bookToEdit: _book),
      ),
    );

    if (updated != null && mounted) {
      await _loadBook();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_book == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookDetails)),
        body: Center(
          child: Text(l10n.noResultsTitle),
        ),
      );
    }

    final book = _book!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.edit,
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
            color: colorScheme.error,
            onPressed: _deleteBook,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Card with Title and Author
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.menu_book,
                          size: 36,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              book.author,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Quantity Row with instant +/- stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.quantity,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      QuantityStepper(
                        quantity: book.quantity,
                        onIncrement: () async {
                          final newQty = book.quantity + 1;
                          await ref
                              .read(bookRepositoryProvider)
                              .updateQuantity(book.id!, newQty);
                          await _loadBook();
                          ref.read(bookListNotifierProvider.notifier).loadBooks();
                        },
                        onDecrement: () async {
                          if (book.quantity <= 1) return;
                          final newQty = book.quantity - 1;
                          await ref
                              .read(bookRepositoryProvider)
                              .updateQuantity(book.id!, newQty);
                          await _loadBook();
                          ref.read(bookListNotifierProvider.notifier).loadBooks();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Metadata Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.category != null && book.category!.isNotEmpty) ...[
                    _buildInfoTile(
                      icon: Icons.category_outlined,
                      label: l10n.category,
                      value: book.category!,
                      colorScheme: colorScheme,
                    ),
                    const Divider(height: 24),
                  ],
                  if (book.isbn != null && book.isbn!.isNotEmpty) ...[
                    _buildInfoTile(
                      icon: Icons.numbers,
                      label: l10n.isbn,
                      value: book.isbn!,
                      colorScheme: colorScheme,
                    ),
                    const Divider(height: 24),
                  ],
                  if (book.publisher != null && book.publisher!.isNotEmpty) ...[
                    _buildInfoTile(
                      icon: Icons.business_outlined,
                      label: l10n.publisher,
                      value: book.publisher!,
                      colorScheme: colorScheme,
                    ),
                    const Divider(height: 24),
                  ],
                  if (book.publicationYear != null) ...[
                    _buildInfoTile(
                      icon: Icons.calendar_today_outlined,
                      label: l10n.publicationYear,
                      value: book.publicationYear.toString(),
                      colorScheme: colorScheme,
                    ),
                    const Divider(height: 24),
                  ],
                  _buildInfoTile(
                    icon: Icons.history,
                    label: l10n.createdAt,
                    value: DateFormatter.formatDate(book.createdAt, locale),
                    colorScheme: colorScheme,
                  ),
                  const Divider(height: 24),
                  _buildInfoTile(
                    icon: Icons.update,
                    label: l10n.updatedAt,
                    value: DateFormatter.formatDate(book.updatedAt, locale),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes Section
          if (book.notes != null && book.notes!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes_outlined, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.notes,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      book.notes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
