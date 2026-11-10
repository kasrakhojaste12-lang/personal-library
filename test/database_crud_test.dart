import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:library_manager/core/database/app_database.dart';
import 'package:library_manager/features/books/domain/models/book.dart';
import 'package:library_manager/features/books/data/repositories/book_repository_impl.dart';

void main() {
  // Initialize FFI for local machine / CI SQLite execution
  sqfliteFfiInit();

  group('Database & BookRepository CRUD Tests', () {
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
        },
      );

      testDb = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: dbOptions,
      );
      appDb = AppDatabase(testDb);
      repository = BookRepositoryImpl(appDb);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Insert a new book and retrieve by ID', () async {
      final book = Book(
        title: 'بوستان سعدی',
        author: 'سعدی شیرازی',
        publisher: 'انتشارات نگاه',
        publicationYear: 1395,
        isbn: '978-964-351-234-5',
        category: 'شعر کهن',
        notes: 'نسخه تصحیح شده',
        quantity: 2,
      );

      final id = await repository.addBook(book);
      expect(id, isPositive);

      final fetched = await repository.getBookById(id);
      expect(fetched, isNotNull);
      expect(fetched!.title, equals('بوستان سعدی'));
      expect(fetched.author, equals('سعدی شیرازی'));
      expect(fetched.quantity, equals(2));
      expect(fetched.normalizedTitle, equals('بوستان سعدی'));
      expect(fetched.normalizedIsbn, equals('9789643512345'));
    });

    test('Update existing book details', () async {
      final book = Book(
        title: 'Clean Architecture',
        author: 'Robert C. Martin',
        quantity: 1,
      );

      final id = await repository.addBook(book);
      final created = await repository.getBookById(id);

      final updatedBook = created!.copyWith(
        title: 'Clean Architecture (2nd Edition)',
        publisher: 'Prentice Hall',
        quantity: 3,
      );

      final success = await repository.updateBook(updatedBook);
      expect(success, isTrue);

      final reFetched = await repository.getBookById(id);
      expect(reFetched!.title, equals('Clean Architecture (2nd Edition)'));
      expect(reFetched.publisher, equals('Prentice Hall'));
      expect(reFetched.quantity, equals(3));
    });

    test('Update book quantity with minimum boundary check', () async {
      final book = Book(
        title: 'دیوان حافظ',
        author: 'حافظ',
        quantity: 3,
      );

      final id = await repository.addBook(book);

      // Increment
      await repository.updateQuantity(id, 4);
      var fetched = await repository.getBookById(id);
      expect(fetched!.quantity, equals(4));

      // Decrement to minimum allowed
      await repository.updateQuantity(id, 1);
      fetched = await repository.getBookById(id);
      expect(fetched!.quantity, equals(1));

      // Attempt invalid decrease below 1 (must be rejected)
      final rejected = await repository.updateQuantity(id, 0);
      expect(rejected, isFalse);
      fetched = await repository.getBookById(id);
      expect(fetched!.quantity, equals(1));
    });

    test('Delete book from database', () async {
      final book = Book(
        title: 'Book to Delete',
        author: 'Author',
      );

      final id = await repository.addBook(book);
      expect(await repository.getBooksCount(), equals(1));

      final deleted = await repository.deleteBook(id);
      expect(deleted, isTrue);

      expect(await repository.getBooksCount(), equals(0));
      expect(await repository.getBookById(id), isNull);
    });
  });
}
