import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Real-time search bar input widget.
class SearchBarWidget extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.initialQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery && _controller.text != widget.initialQuery) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchPlaceholder,
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  tooltip: l10n.clearSearch,
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
