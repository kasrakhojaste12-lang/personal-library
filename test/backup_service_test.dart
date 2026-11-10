import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:library_manager/core/database/app_database.dart';
import 'package:library_manager/features/books/domain/models/book.dart';
import 'package:library_manager/features/books/data/repositories/book_repository_impl.dart';
import 'package:library_manager/features/backup/data/backup_service.dart';

void main() {
  sqfliteFfiInit();

  group('BackupService & Import/Export Tests', () {
    late Database testDb;
    late AppDatabase appDb;
    late BookRepositoryImpl repository;
    late BackupService backupService;

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
        },
      );

      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: dbOptions,
      );
      appDb = AppDatabase(testDb);
      repository = BookRepositoryImpl(appDb);
      backupService = BackupService(repository);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Generates valid JSON backup with metadata and book items', () {
      final books = [
        Book(
          title: 'کتاب اول',
          author: 'نویسنده اول',
          quantity: 2,
        ),
        Book(
          title: 'The Pragmatic Programmer',
          author: 'Andy Hunt & Dave Thomas',
          isbn: '978-0201616224',
          quantity: 1,
        ),
      ];

      final jsonStr = backupService.generateBackupJson(books);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['version'], equals(BackupService.currentBackupVersion));
      expect(decoded['appName'], equals('PersonalLibraryManager'));
      expect(decoded['booksCount'], equals(2));
      expect(decoded['exportDate'], isNotNull);
      expect((decoded['books'] as List).length, equals(2));
    });

    test('Validates and parses healthy JSON payload', () {
      final validJson = jsonEncode({
        'version': 1,
        'appName': 'PersonalLibraryManager',
        'exportDate': DateTime.now().toIso8601String(),
        'booksCount': 1,
        'books': [
          {
            'title': 'هشت کتاب',
            'author': 'سهراب سپهری',
            'quantity': 1,
          }
        ]
      });

      final parsed = backupService.validateAndParseJson(validJson);
      expect(parsed.length, equals(1));
      expect(parsed.first.title, equals('هشت کتاب'));
      expect(parsed.first.author, equals('سهراب سپهری'));
    });

    test('Rejects invalid or corrupted JSON gracefully with descriptive errors', () {
      // Empty string
      expect(
        () => backupService.validateAndParseJson(''),
        throwsA(isA<BackupValidationException>()),
      );

      // Corrupted non-JSON text
      expect(
        () => backupService.validateAndParseJson('Not a JSON string {foo:'),
        throwsA(isA<BackupValidationException>()),
      );

      // Missing version
      expect(
        () => backupService.validateAndParseJson(jsonEncode({'books': []})),
        throwsA(isA<BackupValidationException>()),
      );

      // Empty book title
      final emptyTitleJson = jsonEncode({
        'version': 1,
        'books': [
          {'title': '   ', 'author': 'Valid Author'}
        ]
      });
      expect(
        () => backupService.validateAndParseJson(emptyTitleJson),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('Import: Merge strategy skips exact duplicates and adds new books', () async {
      // Add existing book
      await repository.addBook(Book(
        title: 'بوستان سعدی',
        author: 'سعدی شیرازی',
        isbn: '978-964-111-111-1',
      ));

      // Import list containing duplicate and new book
      final importedBooks = [
        Book(
          title: 'بوستان سعدی', // Exact title & author duplicate
          author: 'سعدی شیرازی',
          isbn: '978-964-111-111-1',
        ),
        Book(
          title: 'مثنوی معنوی', // New unique book
          author: 'مولانا',
          isbn: '978-964-222-222-2',
        ),
      ];

      final result = await repository.mergeBooks(importedBooks);
      expect(result.inserted, equals(1));
      expect(result.skipped, equals(1));

      // Total count in DB should now be 2
      expect(await repository.getBooksCount(), equals(2));
    });

    test('Import: Replace strategy wipes current library and sets new books', () async {
      // Add existing book
      await repository.addBook(Book(
        title: 'Old Book 1',
        author: 'Old Author 1',
      ));
      await repository.addBook(Book(
        title: 'Old Book 2',
        author: 'Old Author 2',
      ));
      expect(await repository.getBooksCount(), equals(2));

      // Replace with single book
      final newBooks = [
        Book(
          title: 'Brand New Book',
          author: 'Brand New Author',
        ),
      ];

      final inserted = await repository.replaceAllBooks(newBooks);
      expect(inserted, equals(1));

      final all = await repository.getAllBooksForExport();
      expect(all.length, equals(1));
      expect(all.first.title, equals('Brand New Book'));
    });
  });
}
