import '../models/book.dart';
import '../models/sort_option.dart';

/// Abstract repository interface for Book operations.
abstract class BookRepository {
  Future<List<Book>> getBooks({
    String? searchQuery,
    BookSortOption sortOption = BookSortOption.dateAddedDesc,
  });

  Future<Book?> getBookById(int id);

  Future<int> addBook(Book book);

  Future<bool> updateBook(Book book);

  Future<bool> deleteBook(int id);

  Future<bool> updateQuantity(int id, int newQuantity);

  Future<int> getBooksCount();

  Future<List<Book>> getAllBooksForExport();

  Future<int> replaceAllBooks(List<Book> books);

  Future<({int inserted, int skipped})> mergeBooks(List<Book> books);
}
