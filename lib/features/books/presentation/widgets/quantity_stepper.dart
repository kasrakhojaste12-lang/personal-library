import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';

/// Reusable stepper widget to increase or decrease book quantity.
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final canDecrement = quantity > 1;

    final displayQuantity = DateFormatter.formatQuantity(quantity, locale);

    if (compact) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: canDecrement ? onDecrement : null,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: canDecrement ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                displayQuantity,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            InkWell(
              onTap: onIncrement,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: canDecrement ? onDecrement : null,
            icon: const Icon(Icons.remove),
            iconSize: 20,
            tooltip: 'Decrease',
            style: IconButton.styleFrom(
              backgroundColor: canDecrement ? colorScheme.surface : Colors.transparent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              displayQuantity,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
            iconSize: 20,
            tooltip: 'Increase',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
