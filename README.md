# Personal Library Manager (100% Offline)

A production-quality, fully offline Android application built with Flutter, Riverpod, and SQLite. Designed with Material 3, bilingual support (English LTR & Persian RTL with bundled Vazirmatn typography), real-time search with Persian/Arabic normalization, and robust JSON backup import/export.

---

## Features

### 1. 100% Offline & Private
- **Zero Network Permissions**: The `android.permission.INTERNET` permission is completely omitted from `AndroidManifest.xml`.
- **Local Storage**: All data is stored locally in an embedded SQLite database (`sqflite`).
- **High Performance**: Features dedicated indices on normalized fields (`normalized_title`, `normalized_author`, `normalized_isbn`, and `created_at`) allowing sub-millisecond lookups and buttery-smooth 60+ FPS scrolling with 5,000+ books.

### 2. Comprehensive Book Management
- **Full Metadata**: Title (required), Author (required), Publisher, Publication Year, ISBN, Category/Genre, Notes, Quantity (min 1, default 1), and automatic `createdAt` / `updatedAt` timestamps.
- **Quick Quantity Adjustment**: Instant `+` and `-` steppers on list cards and the book details view (with minimum 1 constraint).
- **Validation**: Form inputs are validated with friendly localized error messages.
- **Safe Deletion**: Deletion requires explicit confirmation dialog displaying the book's title.

### 3. Real-Time Search & Persistent Sort
- **Persian & Arabic Text Normalization**:
  - Automatically transforms Arabic Yeh (`ي`) and Alef Maksura (`ى`) to Persian Yeh (`ی`).
  - Converts Arabic Kaf (`ك`) to Persian Kaf (`ک`).
  - Strips Arabic/Persian diacritics (Fatha, Damma, Kasra, Tanwin, Shaddah, Sukun, Maddah).
  - Normalizes Alef variations (`أ`, `إ`, `آ`, `ٱ` $\to$ `ا`).
  - Strips Tatweel/Kashida (`ـ`) and handles Zero-Width Non-Joiner (ZWNJ).
  - Unifies Persian/Arabic digits to ASCII digits for consistent ISBN and year lookups.
  - Case-insensitive matching for English.
- **Sort Options**:
  - Title ($A \to Z$ and $Z \to A$)
  - Date Added (Newest first / Oldest first)
  - Selected sort preference is automatically persisted across app restarts using `shared_preferences`.
- **Friendly Empty States**:
  - Empty library: "Your library is empty" with an action button to add your first book.
  - No matching results: "No books found" with an action button to clear search.

### 4. Backup & Restore (JSON Export & Import)
- **JSON Schema**: Includes `version: 1`, `appName`, `exportDate`, `booksCount`, and complete book records.
- **Export**:
  - Save directly to device storage (Downloads / Documents) via the system file picker.
  - Share via Android system share sheet (Nearby Share, Bluetooth, messaging apps).
- **Import with Safety**:
  - Strict validation of JSON syntax, structure, data types, and required fields.
  - Corrupted or invalid files are cleanly rejected with human-readable error messages without modifying or endangering existing data.
  - Modal choice:
    - **Merge with existing data**: Detects and skips exact duplicates (matching normalized title + author or identical ISBN) while adding new books.
    - **Replace all existing data**: Atomically clears the current collection and restores the backup.
  - Displays a detailed summary dialog upon completion (e.g. "42 books imported, 3 skipped").

### 5. Localization & Typography
- **Bilingual**: English (`en`) and Persian (`fa`), selectable in Settings.
- **Default Resolution**: Automatically defaults to device language on first launch and persists the user's manual selection.
- **Full RTL / LTR**: Seamless right-to-left layout for Persian and left-to-right for English.
- **Bundled Font**: Bundles Rastikerdar's **Vazirmatn** font (`assets/fonts/Vazirmatn-Regular.ttf` & `Vazirmatn-Bold.ttf`) directly inside the APK for offline rendering.
- **100% Localized**: Zero hardcoded strings; all texts are defined in `app_en.arb` and `app_fa.arb`.

### 6. Material 3 Design & Themes
- Light Theme and Dark Theme with high contrast and accessible colors.
- Theme mode selector: System Default, Light, or Dark (persisted).

---

## Project Structure

```
lib/
├── core/
│   ├── database/
│   │   ├── app_database.dart         # SQLite manager, table creation, migrations, indices
│   │   └── database_provider.dart    # Riverpod database & repository providers
│   ├── localization/
│   │   └── locale_provider.dart      # Persisted locale notifier (device default fallback)
│   ├── theme/
│   │   ├── app_theme.dart            # Material 3 light/dark theme definitions
│   │   └── theme_provider.dart       # Persisted theme mode notifier
│   └── utils/
│       ├── date_formatter.dart       # Localized date and numeral formatters
│       └── persian_normalizer.dart   # Persian/Arabic/English normalizer & diacritic stripper
├── features/
│   ├── backup/
│   │   ├── data/
│   │   │   └── backup_service.dart   # JSON serialization, validator, file picker & share
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── backup_provider.dart
│   │       └── widgets/
│   │           └── import_dialog.dart # Merge vs Replace selection dialog
│   ├── books/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── book_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── book.dart         # Book entity with copyWith, validation, and JSON mapping
│   │   │   │   └── sort_option.dart  # Sort enums and SQL ORDER BY clauses
│   │   │   └── repositories/
│   │   │       └── book_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── book_providers.dart # Riverpod state notifiers for reactive UI
│   │       ├── screens/
│   │       │   ├── add_edit_book_screen.dart # Form with validation
│   │       │   ├── book_details_screen.dart  # Full metadata, stepper, delete confirmation
│   │       │   └── book_list_screen.dart     # Search bar, sort bottom sheet, lazy list, FAB
│   │       └── widgets/
│   │           ├── book_card.dart
│   │           ├── empty_state_view.dart
│   │           ├── quantity_stepper.dart
│   │           ├── search_bar_widget.dart
│   │           └── sort_filter_bottom_sheet.dart
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart # Theme, language, export/import management
├── l10n/
│   ├── app_en.arb                    # English translation catalogue
│   ├── app_fa.arb                    # Persian translation catalogue
│   └── app_localizations.dart        # Type-safe localization delegates & lookups
└── main.dart                         # Entry point with SharedPreferences & ProviderScope
```

---

## Setup & Running

### Prerequisites
- Flutter SDK $\ge$ 3.19.0 (Dart $\ge$ 3.3.0)
- Android SDK with `minSdkVersion 24` and `targetSdkVersion 34`
- Java Development Kit (JDK 17)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Static Analysis
Ensure code meets strict linting standards:
```bash
flutter analyze
```

### 3. Run Unit Tests
Run the automated test suite verifying CRUD operations, Persian text normalization, search queries, sort orders, and JSON backup import/export:
```bash
flutter test
```

### 4. Run the App
Launch on an Android device or emulator:
```bash
flutter run
```

---

## Building a Release APK

### Standard Release APK
To build a universal release APK:
```bash
flutter build apk --release
```
The output file will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### Split per ABI (Optimized Size)
To produce smaller architecture-specific APKs (`armeabi-v7a`, `arm64-v8a`, `x86_64`):
```bash
flutter build apk --release --split-per-abi
```
The resulting APKs will be located in:
`build/app/outputs/flutter-apk/`

### App Bundle for Google Play
To generate an Android App Bundle (AAB):
```bash
flutter build appbundle --release
```
The output file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`
