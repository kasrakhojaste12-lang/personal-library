/// Supported sort options for the book collection.
enum BookSortOption {
  titleAsc,
  titleDesc,
  dateAddedDesc,
  dateAddedAsc;

  String get key => name;

  static BookSortOption fromKey(String? key) {
    if (key == null) return BookSortOption.dateAddedDesc;
    return BookSortOption.values.firstWhere(
      (element) => element.name == key,
      orElse: () => BookSortOption.dateAddedDesc,
    );
  }

  /// SQL ORDER BY clause snippet for optimized database sorting.
  String get sqlOrderBy {
    switch (this) {
      case BookSortOption.titleAsc:
        return 'normalized_title COLLATE NOCASE ASC, id ASC';
      case BookSortOption.titleDesc:
        return 'normalized_title COLLATE NOCASE DESC, id DESC';
      case BookSortOption.dateAddedDesc:
        return 'created_at DESC, id DESC';
      case BookSortOption.dateAddedAsc:
        return 'created_at ASC, id ASC';
    }
  }
}
