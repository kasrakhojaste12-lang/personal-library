import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../books/domain/models/book.dart';
import '../../books/presentation/providers/book_providers.dart';
import '../data/backup_service.dart';

sealed class BackupState {
  const BackupState();
}

class BackupIdle extends BackupState {
  const BackupIdle();
}

class BackupLoading extends BackupState {
  final String message;
  const BackupLoading(this.message);
}

class BackupExportSuccess extends BackupState {
  final String filePath;
  const BackupExportSuccess(this.filePath);
}

class BackupImportSuccess extends BackupState {
  final int imported;
  final int skipped;
  const BackupImportSuccess({required this.imported, required this.skipped});
}

class BackupError extends BackupState {
  final String error;
  const BackupError(this.error);
}

class BackupNotifier extends StateNotifier<BackupState> {
  final BackupService _backupService;
  final Ref _ref;

  BackupNotifier(this._backupService, this._ref) : super(const BackupIdle());

  void reset() {
    state = const BackupIdle();
  }

  Future<void> exportAndShare() async {
    state = const BackupLoading('Exporting backup...');
    try {
      final path = await _backupService.exportAndShare();
      state = BackupExportSuccess(path);
    } catch (e) {
      state = BackupError(e.toString());
    }
  }

  Future<void> exportToSavedFile() async {
    state = const BackupLoading('Saving backup...');
    try {
      final path = await _backupService.exportToSavedFile();
      if (path != null) {
        state = BackupExportSuccess(path);
      } else {
        state = const BackupIdle(); // Cancelled
      }
    } catch (e) {
      state = BackupError(e.toString());
    }
  }

  Future<List<Book>?> pickAndValidateBackup() async {
    state = const BackupLoading('Validating backup file...');
    try {
      final books = await _backupService.pickAndValidateBackupFile();
      state = const BackupIdle();
      return books;
    } catch (e) {
      state = BackupError(e.toString());
      return null;
    }
  }

  Future<void> executeImport({
    required List<Book> books,
    required bool replaceExisting,
  }) async {
    state = const BackupLoading('Restoring books into library...');
    try {
      final repository = _ref.read(bookRepositoryProvider);
      int imported = 0;
      int skipped = 0;

      if (replaceExisting) {
        imported = await repository.replaceAllBooks(books);
        skipped = 0;
      } else {
        final result = await repository.mergeBooks(books);
        imported = result.inserted;
        skipped = result.skipped;
      }

      // Refresh collection in memory
      await _ref.read(bookListNotifierProvider.notifier).loadBooks();
      state = BackupImportSuccess(imported: imported, skipped: skipped);
    } catch (e) {
      state = BackupError('Import failed: ${e.toString()}');
    }
  }
}

final backupNotifierProvider = StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  final service = ref.watch(backupServiceProvider);
  return BackupNotifier(service, ref);
});
