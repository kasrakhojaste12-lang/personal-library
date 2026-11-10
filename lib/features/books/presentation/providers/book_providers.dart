import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../domain/models/book.dart';
import '../../domain/models/sort_option.dart';
import '../../domain/repositories/book_repository.dart';

const String _prefSortKey = 'app_book_sort_option';

/// Persisted Sort Option Provider
class SortOptionNotifier extends StateNotifier<BookSortOption> {
  final SharedPreferences _prefs;

  SortOptionNotifier(this._prefs) : super(_loadInitialSort(_prefs));

  static BookSortOption _loadInitialSort(SharedPreferences prefs) {
    final saved = prefs.getString(_prefSortKey);
    return BookSortOption.fromKey(saved);
  }

  Future<void> setSortOption(BookSortOption option) async {
    state = option;
    await _prefs.setString(_prefSortKey, option.key);
  }
}

final sortOptionProvider = StateNotifierProvider<SortOptionNotifier, BookSortOption>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SortOptionNotifier(prefs);
});

/// Real-time search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Book list state notifier managing reactive collection
class BookListNotifier extends StateNotifier<AsyncValue<List<Book>>> {
  final BookRepository _repository;
  final Ref _ref;

  BookListNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    final query = _ref.read(searchQueryProvider);
    final sort = _ref.read(sortOptionProvider);

    try {
      final books = await _repository.getBooks(
        searchQuery: query,
        sortOption: sort,
      );
      state = AsyncValue.data(books);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> addBook(Book book) async {
    final id = await _repository.addBook(book);
    await loadBooks();
    return id;
  }

  Future<bool> updateBook(Book book) async {
    final success = await _repository.updateBook(book);
    await loadBooks();
    return success;
  }

  Future<bool> deleteBook(int id) async {
    final success = await _repository.deleteBook(id);
    await loadBooks();
    return success;
  }

  Future<void> incrementQuantity(Book book) async {
    if (book.id == null) return;
    final newQty = book.quantity + 1;
    await _repository.updateQuantity(book.id!, newQty);
    await loadBooks();
  }

  Future<void> decrementQuantity(Book book) async {
    if (book.id == null || book.quantity <= 1) return;
    final newQty = book.quantity - 1;
    await _repository.updateQuantity(book.id!, newQty);
    await loadBooks();
  }
}

final bookListNotifierProvider = StateNotifierProvider<BookListNotifier, AsyncValue<List<Book>>>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  final notifier = BookListNotifier(repository, ref);

  // Automatically refresh books when search query or sort option changes
  ref.listen<String>(searchQueryProvider, (_, __) => notifier.loadBooks());
  ref.listen<BookSortOption>(sortOptionProvider, (_, __) => notifier.loadBooks());

  return notifier;
});

/// Total count of books in library
final totalBooksCountProvider = FutureProvider<int>((ref) async {
  // Watch list provider so count invalidates when collection changes
  ref.watch(bookListNotifierProvider);
  final repo = ref.watch(bookRepositoryProvider);
  return await repo.getBooksCount();
});
