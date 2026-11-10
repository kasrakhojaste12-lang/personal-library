import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/books/domain/models/book.dart';
import '../../features/books/domain/models/sort_option.dart';
import '../utils/persian_normalizer.dart';

/// Database manager for the offline personal library.
///
/// Features indexed tables, optimized full-text matching for Persian/Arabic/English,
/// atomic transactions for imports, and lazy-ready queries for 5,000+ books.
class AppDatabase {
  static const String _dbName = 'library_manager.db';
  static const int _dbVersion = 1;
  static const String tableBooks = 'books';

  Database? _db;

  AppDatabase([Database? db]) : _db = db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableBooks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        publisher TEXT,
        publication_year INTEGER,
        isbn TEXT,
        category TEXT,
        notes TEXT,
        quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 1),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        normalized_title TEXT NOT NULL,
        normalized_author TEXT NOT NULL,
        normalized_isbn TEXT NOT NULL
      );
    ''');

    // Create indices to ensure fast queries with 5,000+ items
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_norm_title ON $tableBooks(normalized_title);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_norm_author ON $tableBooks(normalized_author);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_norm_isbn ON $tableBooks(normalized_isbn);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_books_created_at ON $tableBooks(created_at DESC);',
    );
  }

  /// Inserts a new book into the database and returns the generated ID.
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(
      tableBooks,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Updates an existing book.
  Future<int> updateBook(Book book) async {
    final db = await database;
    if (book.id == null) return 0;
    return await db.update(
      tableBooks,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  /// Deletes a book by its ID.
  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete(
      tableBooks,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Quickly updates the quantity of a book (minimum 1).
  Future<int> updateQuantity(int id, int newQuantity) async {
    if (newQuantity < 1) return 0;
    final db = await database;
    return await db.update(
      tableBooks,
      {
        'quantity': newQuantity,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves a single book by ID.
  Future<Book?> getBookById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves books with real-time search and sorting.
  ///
  /// Searches against normalized title, author, and ISBN fields with wildcard support.
  Future<List<Book>> getBooks({
    String? searchQuery,
    BookSortOption sortOption = BookSortOption.dateAddedDesc,
  }) async {
    final db = await database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final normalizedQuery = PersianNormalizer.normalize(searchQuery);
      final normalizedIsbnQuery = PersianNormalizer.normalizeIsbn(searchQuery);

      whereClause = '''
        normalized_title LIKE ? OR
        normalized_author LIKE ? OR
        (? != '' AND normalized_isbn LIKE ?)
      ''';
      whereArgs = [
        '%$normalizedQuery%',
        '%$normalizedQuery%',
        normalizedIsbnQuery,
        '%$normalizedIsbnQuery%',
      ];
    }

    final result = await db.query(
      tableBooks,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: sortOption.sqlOrderBy,
    );

    return result.map((map) => Book.fromMap(map)).toList();
  }

  /// Returns total count of books in the library.
  Future<int> getBooksCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableBooks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clears all books from the database.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableBooks);
  }

  /// Atomic replacement of all books with a new collection (used in "Replace all" import).
  Future<int> replaceAllBooks(List<Book> books) async {
    final db = await database;
    return await db.transaction<int>((txn) async {
      await txn.delete(tableBooks);
      var inserted = 0;
      final batch = txn.batch();
      for (final book in books) {
        batch.insert(tableBooks, book.toMap());
        inserted++;
      }
      await batch.commit(noResult: true);
      return inserted;
    });
  }

  /// Atomic batch import with duplicate skipping (used in "Merge" import).
  ///
  /// Returns a record of (insertedCount, skippedCount).
  Future<({int inserted, int skipped})> mergeBooks(List<Book> books) async {
    final db = await database;
    return await db.transaction<({int inserted, int skipped})>((txn) async {
      // Query existing books to check for duplicates
      final existingRows = await txn.query(
        tableBooks,
        columns: ['normalized_title', 'normalized_author', 'normalized_isbn'],
      );

      final existingTitleAuthors = <String>{};
      final existingIsbns = <String>{};

      for (final row in existingRows) {
        final title = (row['normalized_title'] as String?) ?? '';
        final author = (row['normalized_author'] as String?) ?? '';
        final isbn = (row['normalized_isbn'] as String?) ?? '';

        if (title.isNotEmpty && author.isNotEmpty) {
          existingTitleAuthors.add('$title|$author');
        }
        if (isbn.isNotEmpty) {
          existingIsbns.add(isbn);
        }
      }

      var inserted = 0;
      var skipped = 0;
      final batch = txn.batch();

      for (final book in books) {
        final titleAuthorKey = '${book.normalizedTitle}|${book.normalizedAuthor}';
        final hasIsbn = book.normalizedIsbn.isNotEmpty;

        // Skip exact duplicate if same title+author OR same ISBN exists
        final isDuplicate = existingTitleAuthors.contains(titleAuthorKey) ||
            (hasIsbn && existingIsbns.contains(book.normalizedIsbn));

        if (isDuplicate) {
          skipped++;
        } else {
          batch.insert(tableBooks, book.toMap());
          existingTitleAuthors.add(titleAuthorKey);
          if (hasIsbn) {
            existingIsbns.add(book.normalizedIsbn);
          }
          inserted++;
        }
      }

      await batch.commit(noResult: true);
      return (inserted: inserted, skipped: skipped);
    });
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
