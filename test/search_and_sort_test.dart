import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:library_manager/core/database/app_database.dart';
import 'package:library_manager/features/books/domain/models/book.dart';
import 'package:library_manager/features/books/domain/models/sort_option.dart';
import 'package:library_manager/features/books/data/repositories/book_repository_impl.dart';

void main() {
  sqfliteFfiInit();

  group('Search and Sort Database Tests', () {
    late Database testDb;
    late AppDatabase appDb;
    late BookRepositoryImpl repository;

    setUp(() async {
      final dbOptions = OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppDatabase.tableBooks} (
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
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_books_norm_title ON ${AppDatabase.tableBooks}(normalized_title);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_books_norm_author ON ${AppDatabase.tableBooks}(normalized_author);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_books_norm_isbn ON ${AppDatabase.tableBooks}(normalized_isbn);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_books_created_at ON ${AppDatabase.tableBooks}(created_at DESC);',
          );
        },
      );

      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: dbOptions,
      );
      appDb = AppDatabase(testDb);
      repository = BookRepositoryImpl(appDb);

      // Seed books
      final now = DateTime.now();
      await repository.addBook(Book(
        title: 'شاهنامه فردوسی',
        author: 'ابوالقاسم فردوسی',
        isbn: '978-964-111-001-1',
        createdAt: now.subtract(const Duration(days: 10)),
      ));
      await repository.addBook(Book(
        title: 'دیوان شمس تبریزی',
        author: 'مولانا جلال‌الدین بلخی',
        isbn: '978-964-222-002-2',
        createdAt: now.subtract(const Duration(days: 5)),
      ));
      await repository.addBook(Book(
        title: 'گلستان سعدی',
        author: 'مصلح‌الدین سعدی شیرازی',
        isbn: '978-964-333-003-3',
        createdAt: now.subtract(const Duration(days: 2)),
      ));
      await repository.addBook(Book(
        title: 'Clean Code',
        author: 'Robert C. Martin',
        isbn: '978-0-13-235088-4',
        createdAt: now,
      ));
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Real-time search matching Arabic Yeh and Kaf characters', () async {
      // User types with Arabic keyboard: "فردوسى" (Arabic Yeh \u0649)
      final results1 = await repository.getBooks(searchQuery: 'فردوسى');
      expect(results1.length, equals(1));
      expect(results1.first.title, equals('شاهنامه فردوسی'));

      // User types with Arabic Kaf: "كتاب" or search query for "شمس"
      final results2 = await repository.getBooks(searchQuery: 'شمس');
      expect(results2.length, equals(1));
      expect(results2.first.title, equals('دیوان شمس تبریزی'));
    });

    test('Real-time search with Persian/Arabic diacritics ignored', () async {
      // User types with diacritics: "گُلِستان"
      final results = await repository.getBooks(searchQuery: 'گُلِستان');
      expect(results.length, equals(1));
      expect(results.first.title, equals('گلستان سعدی'));
    });

    test('Search by ISBN ignoring hyphens and formatting', () async {
      final results = await repository.getBooks(searchQuery: '9780132350884');
      expect(results.length, equals(1));
      expect(results.first.title, equals('Clean Code'));
    });

    test('Search with English case insensitivity', () async {
      final results = await repository.getBooks(searchQuery: 'clean code');
      expect(results.length, equals(1));
      expect(results.first.title, equals('Clean Code'));
    });

    test('Sort by Date Added Descending (Newest first)', () async {
      final results = await repository.getBooks(
        sortOption: BookSortOption.dateAddedDesc,
      );
      expect(results.first.title, equals('Clean Code'));
      expect(results.last.title, equals('شاهنامه فردوسی'));
    });

    test('Sort by Date Added Ascending (Oldest first)', () async {
      final results = await repository.getBooks(
        sortOption: BookSortOption.dateAddedAsc,
      );
      expect(results.first.title, equals('شاهنامه فردوسی'));
      expect(results.last.title, equals('Clean Code'));
    });

    test('Sort Alphabetically by Title Ascending', () async {
      final results = await repository.getBooks(
        sortOption: BookSortOption.titleAsc,
      );
      // Clean Code (C), دیوان (د), شاهنامه (ش), گلستان (گ)
      expect(results.first.title, equals('Clean Code'));
    });
  });
}
