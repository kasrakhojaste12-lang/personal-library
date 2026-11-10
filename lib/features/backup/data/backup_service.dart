import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../books/domain/models/book.dart';
import '../../books/domain/repositories/book_repository.dart';

/// Exception thrown when a backup file fails validation.
class BackupValidationException implements Exception {
  final String message;
  BackupValidationException(this.message);

  @override
  String toString() => message;
}

/// Service handling JSON backup export and secure import.
class BackupService {
  final BookRepository _bookRepository;

  static const int currentBackupVersion = 1;

  BackupService(this._bookRepository);

  /// Generates the formatted JSON string representing the backup payload.
  String generateBackupJson(List<Book> books) {
    final payload = {
      'version': currentBackupVersion,
      'appName': 'PersonalLibraryManager',
      'exportDate': DateTime.now().toUtc().toIso8601String(),
      'booksCount': books.length,
      'books': books.map((b) => b.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Exports the library and shares it via the Android share sheet or saves it.
  Future<String> exportAndShare() async {
    final books = await _bookRepository.getAllBooksForExport();
    final jsonString = generateBackupJson(books);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/library_backup_$timestamp.json';

    final file = File(filePath);
    await file.writeAsString(jsonString, flush: true);

    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'application/json')],
      subject: 'Personal Library Backup ($timestamp)',
      text: 'Exported ${books.length} books from Personal Library.',
    );

    return filePath;
  }

  /// Exports the library and prompts the user with the system file picker to save it.
  Future<String?> exportToSavedFile() async {
    final books = await _bookRepository.getAllBooksForExport();
    final jsonString = generateBackupJson(books);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'library_backup_$timestamp.json';

    final outputBytes = utf8.encode(jsonString);

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Library Backup',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: outputBytes,
    );

    if (outputPath != null && File(outputPath).existsSync() == false) {
      final file = File(outputPath);
      await file.writeAsString(jsonString, flush: true);
    }

    return outputPath;
  }

  /// Validates raw JSON string and converts it into a list of [Book]s.
  ///
  /// Throws [BackupValidationException] if the file is invalid or corrupted.
  List<Book> validateAndParseJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw BackupValidationException('The selected file is empty.');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      throw BackupValidationException('Invalid JSON format: unable to parse file.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw BackupValidationException('Invalid backup structure: root must be a JSON object.');
    }

    final version = decoded['version'];
    if (version == null || version is! int || version < 1) {
      throw BackupValidationException('Unsupported or missing backup version in file.');
    }

    final rawBooks = decoded['books'];
    if (rawBooks == null || rawBooks is! List) {
      throw BackupValidationException("The file is missing the required 'books' list.");
    }

    final books = <Book>[];
    for (var i = 0; i < rawBooks.length; i++) {
      final item = rawBooks[i];
      if (item is! Map<String, dynamic>) {
        throw BackupValidationException('Corrupted book entry at row ${i + 1}.');
      }

      try {
        final book = Book.fromJson(item);
        if (!book.isValid) {
          throw BackupValidationException(
            'Book at row ${i + 1} has invalid title, author, or quantity.',
          );
        }
        books.add(book);
      } catch (e) {
        throw BackupValidationException('Error reading book #${i + 1}: ${e.toString()}');
      }
    }

    return books;
  }

  /// Prompts user to pick a JSON file, validates it, and returns the parsed books.
  Future<List<Book>?> pickAndValidateBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null; // User cancelled
    }

    final file = result.files.first;
    String content;

    if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      final ioFile = File(file.path!);
      content = await ioFile.readAsString();
    } else {
      throw BackupValidationException('Could not read file data.');
    }

    return validateAndParseJson(content);
  }
}
