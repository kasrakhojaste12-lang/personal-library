import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../../features/books/domain/repositories/book_repository.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/backup/data/backup_service.dart';

/// Provider for SQLite database singleton.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider for BookRepository.
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BookRepositoryImpl(db);
});

/// Provider for BackupService.
final backupServiceProvider = Provider<BackupService>((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return BackupService(repo);
});
