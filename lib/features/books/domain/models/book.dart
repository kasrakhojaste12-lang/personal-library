import '../../../../core/utils/persian_normalizer.dart';

/// Represents a book entity in the personal library.
class Book {
  final int? id;
  final String title;
  final String author;
  final String? publisher;
  final int? publicationYear;
  final String? isbn;
  final String? category;
  final String? notes;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Normalized search fields for indexed SQLite queries
  final String normalizedTitle;
  final String normalizedAuthor;
  final String normalizedIsbn;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.publisher,
    this.publicationYear,
    this.isbn,
    this.category,
    this.notes,
    int quantity = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? normalizedTitle,
    String? normalizedAuthor,
    String? normalizedIsbn,
  })  : quantity = quantity < 1 ? 1 : quantity,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        normalizedTitle = normalizedTitle ?? PersianNormalizer.normalize(title),
        normalizedAuthor = normalizedAuthor ?? PersianNormalizer.normalize(author),
        normalizedIsbn = normalizedIsbn ?? PersianNormalizer.normalizeIsbn(isbn);

  /// Validates whether the book meets business rules.
  bool get isValid => title.trim().isNotEmpty && author.trim().isNotEmpty && quantity >= 1;

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? publisher,
    int? publicationYear,
    String? isbn,
    String? category,
    String? notes,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newTitle = title ?? this.title;
    final newAuthor = author ?? this.author;
    final newIsbn = isbn ?? this.isbn;

    return Book(
      id: id ?? this.id,
      title: newTitle,
      author: newAuthor,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      isbn: newIsbn,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      normalizedTitle: PersianNormalizer.normalize(newTitle),
      normalizedAuthor: PersianNormalizer.normalize(newAuthor),
      normalizedIsbn: PersianNormalizer.normalizeIsbn(newIsbn),
    );
  }

  /// Converts the book to a Map for SQLite insertion/updates.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title.trim(),
      'author': author.trim(),
      'publisher': publisher?.trim().isEmpty == true ? null : publisher?.trim(),
      'publication_year': publicationYear,
      'isbn': isbn?.trim().isEmpty == true ? null : isbn?.trim(),
      'category': category?.trim().isEmpty == true ? null : category?.trim(),
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      'quantity': quantity < 1 ? 1 : quantity,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'normalized_title': normalizedTitle,
      'normalized_author': normalizedAuthor,
      'normalized_isbn': normalizedIsbn,
    };
  }

  /// Recreates a Book from an SQLite row.
  factory Book.fromMap(Map<String, dynamic> map) {
    final title = (map['title'] as String?) ?? '';
    final author = (map['author'] as String?) ?? '';
    final isbn = map['isbn'] as String?;

    return Book(
      id: map['id'] as int?,
      title: title,
      author: author,
      publisher: map['publisher'] as String?,
      publicationYear: map['publication_year'] as int?,
      isbn: isbn,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
      quantity: (map['quantity'] as int?) ?? 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int?) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int?) ?? 0),
      normalizedTitle: map['normalized_title'] as String? ?? PersianNormalizer.normalize(title),
      normalizedAuthor: map['normalized_author'] as String? ?? PersianNormalizer.normalize(author),
      normalizedIsbn: map['normalized_isbn'] as String? ?? PersianNormalizer.normalizeIsbn(isbn),
    );
  }

  /// Converts Book to JSON format for backup export.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'publisher': publisher,
      'publicationYear': publicationYear,
      'isbn': isbn,
      'category': category,
      'notes': notes,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Reconstructs a Book from JSON import data with error tolerance.
  factory Book.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? json['Title'] ?? '').toString().trim();
    final author = (json['author'] ?? json['Author'] ?? '').toString().trim();

    if (title.isEmpty) {
      throw const FormatException('Book title cannot be empty.');
    }
    if (author.isEmpty) {
      throw const FormatException('Book author cannot be empty.');
    }

    int? pubYear;
    final rawYear = json['publicationYear'] ?? json['publication_year'];
    if (rawYear != null) {
      if (rawYear is int) {
        pubYear = rawYear;
      } else {
        pubYear = int.tryParse(rawYear.toString());
      }
    }

    int qty = 1;
    final rawQty = json['quantity'];
    if (rawQty != null) {
      if (rawQty is int) {
        qty = rawQty;
      } else {
        qty = int.tryParse(rawQty.toString()) ?? 1;
      }
    }
    if (qty < 1) qty = 1;

    DateTime created = DateTime.now();
    final rawCreated = json['createdAt'] ?? json['created_at'];
    if (rawCreated != null) {
      if (rawCreated is int) {
        created = DateTime.fromMillisecondsSinceEpoch(rawCreated);
      } else {
        created = DateTime.tryParse(rawCreated.toString()) ?? DateTime.now();
      }
    }

    DateTime updated = DateTime.now();
    final rawUpdated = json['updatedAt'] ?? json['updated_at'];
    if (rawUpdated != null) {
      if (rawUpdated is int) {
        updated = DateTime.fromMillisecondsSinceEpoch(rawUpdated);
      } else {
        updated = DateTime.tryParse(rawUpdated.toString()) ?? DateTime.now();
      }
    }

    final isbn = json['isbn']?.toString();

    return Book(
      title: title,
      author: author,
      publisher: json['publisher']?.toString(),
      publicationYear: pubYear,
      isbn: isbn,
      category: json['category']?.toString(),
      notes: json['notes']?.toString(),
      quantity: qty,
      createdAt: created,
      updatedAt: updated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          author == other.author &&
          publisher == other.publisher &&
          publicationYear == other.publicationYear &&
          isbn == other.isbn &&
          category == other.category &&
          notes == other.notes &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      author.hashCode ^
      publisher.hashCode ^
      publicationYear.hashCode ^
      isbn.hashCode ^
      category.hashCode ^
      notes.hashCode ^
      quantity.hashCode;
}
