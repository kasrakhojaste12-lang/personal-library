import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/book.dart';
import '../providers/book_providers.dart';

/// Screen for adding a new book or editing an existing one.
class AddEditBookScreen extends ConsumerStatefulWidget {
  final Book? bookToEdit;

  const AddEditBookScreen({super.key, this.bookToEdit});

  @override
  ConsumerState<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends ConsumerState<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _publisherController;
  late final TextEditingController _yearController;
  late final TextEditingController _isbnController;
  late final TextEditingController _categoryController;
  late final TextEditingController _notesController;

  int _quantity = 1;
  bool _isSaving = false;

  bool get _isEditing => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    final book = widget.bookToEdit;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _publisherController = TextEditingController(text: book?.publisher ?? '');
    _yearController = TextEditingController(
      text: book?.publicationYear != null ? book!.publicationYear.toString() : '',
    );
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _categoryController = TextEditingController(text: book?.category ?? '');
    _notesController = TextEditingController(text: book?.notes ?? '');
    _quantity = book?.quantity ?? 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _isbnController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);

    try {
      final yearText = _yearController.text.trim();
      final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;

      final bookData = Book(
        id: widget.bookToEdit?.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        publisher: _publisherController.text.trim().isEmpty ? null : _publisherController.text.trim(),
        publicationYear: year,
        isbn: _isbnController.text.trim().isEmpty ? null : _isbnController.text.trim(),
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        quantity: _quantity,
        createdAt: widget.bookToEdit?.createdAt,
      );

      final notifier = ref.read(bookListNotifierProvider.notifier);

      if (_isEditing) {
        await notifier.updateBook(bookData);
      } else {
        await notifier.addBook(bookData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookSaved),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(bookData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorOccurred}: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editBook : l10n.addBook),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _saveBook,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(l10n.save),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Title Field (Required)
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${l10n.title} *',
                  hintText: l10n.titleRequired,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Author Field (Required)
              TextFormField(
                controller: _authorController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${l10n.author} *',
                  hintText: l10n.authorRequired,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.authorRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category / Genre (Optional)
              TextFormField(
                controller: _categoryController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  hintText: l10n.optional,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // ISBN (Optional)
              TextFormField(
                controller: _isbnController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: l10n.isbn,
                  hintText: 'e.g. 978-3-16-148410-0 (${l10n.optional})',
                  prefixIcon: const Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),

              // Publisher (Optional)
              TextFormField(
                controller: _publisherController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.publisher,
                  hintText: l10n.optional,
                  prefixIcon: const Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Publication Year (Optional)
              TextFormField(
                controller: _yearController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: l10n.publicationYear,
                  hintText: 'e.g. 2024 (${l10n.optional})',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final year = int.tryParse(val.trim());
                    if (year == null || year < 100 || year > 2200) {
                      return l10n.invalidYearError;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Quantity Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          l10n.quantity,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: colorScheme.primary,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _quantity.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes (Optional, Multiline)
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  hintText: l10n.optional,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 56),
                    child: Icon(Icons.notes_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Primary Save Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveBook,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? l10n.save : (_isEditing ? l10n.save : l10n.addBook),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
