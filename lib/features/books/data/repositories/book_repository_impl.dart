import '../../../../core/database/app_database.dart';
import '../../domain/models/book.dart';
import '../../domain/models/sort_option.dart';
import '../../domain/repositories/book_repository.dart';

/// Concrete implementation of [BookRepository] backed by SQLite [AppDatabase].
class BookRepositoryImpl implements BookRepository {
  final AppDatabase _database;

  BookRepositoryImpl(this._database);

  @override
  Future<List<Book>> getBooks({
    String? searchQuery,
    BookSortOption sortOption = BookSortOption.dateAddedDesc,
  }) async {
    return await _database.getBooks(
      searchQuery: searchQuery,
      sortOption: sortOption,
    );
  }

  @override
  Future<Book?> getBookById(int id) async {
    return await _database.getBookById(id);
  }

  @override
  Future<int> addBook(Book book) async {
    return await _database.insertBook(book);
  }

  @override
  Future<bool> updateBook(Book book) async {
    final rows = await _database.updateBook(book);
    return rows > 0;
  }

  @override
  Future<bool> deleteBook(int id) async {
    final rows = await _database.deleteBook(id);
    return rows > 0;
  }

  @override
  Future<bool> updateQuantity(int id, int newQuantity) async {
    final rows = await _database.updateQuantity(id, newQuantity);
    return rows > 0;
  }

  @override
  Future<int> getBooksCount() async {
    return await _database.getBooksCount();
  }

  @override
  Future<List<Book>> getAllBooksForExport() async {
    return await _database.getBooks(sortOption: BookSortOption.dateAddedAsc);
  }

  @override
  Future<int> replaceAllBooks(List<Book> books) async {
    return await _database.replaceAllBooks(books);
  }

  @override
  Future<({int inserted, int skipped})> mergeBooks(List<Book> books) async {
    return await _database.mergeBooks(books);
  }
}
