import 'package:flutter/material.dart';
import '../../domain/models/book.dart';
import 'quantity_stepper.dart';

/// Presentation card displaying a book item in the library list.
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book icon avatar
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book,
                    color: colorScheme.primary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Author, and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Badges row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (book.category != null && book.category!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.category!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (book.publicationYear != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.publicationYear.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Quantity Stepper
              QuantityStepper(
                quantity: book.quantity,
                onIncrement: onIncrementQuantity,
                onDecrement: onDecrementQuantity,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
