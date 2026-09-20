# DocScan – Smart Document Scanner & Text Extractor

A Flutter app that turns your phone camera into a document scanner:
capture a page → extract its text on-device with OCR → save it locally →
export a clean PDF. Works fully offline.

## Features implemented (MVP)
- Capture a document photo (camera or gallery)
- On-device OCR text extraction (Google ML Kit — no internet required)
- Edit the extracted text before saving
- Local storage of all documents (SQLite via `sqflite`) — title, image, text, date
- Document list (home screen) with preview + text snippet
- Document detail view: full image + extracted text, copy text, delete
- Export any saved document as a PDF (image + text) and share it

## Project structure
```
lib/
  main.dart                        # App entry point
  models/
    scanned_document.dart          # Data model
  services/
    database_helper.dart           # SQLite CRUD (local storage)
    ocr_service.dart                # Google ML Kit text recognition wrapper
    pdf_service.dart                # Builds exportable PDF
  screens/
    home_screen.dart               # List of saved documents
    scan_screen.dart               # Capture + OCR + save flow
    document_detail_screen.dart    # View / export / delete a document
```

## How to run this project

You need Flutter SDK installed (flutter.dev/docs/get-started/install) and
a physical Android/iOS device or emulator.

1. **Create a fresh Flutter project shell** (this generates the
   android/ios native folders properly for your machine):
   ```bash
   flutter create docscan
   ```

2. **Replace the generated `lib/` folder and `pubspec.yaml`** with the
   ones from this project (copy all files from this zip into the new
   `docscan/` folder, overwriting `lib/` and `pubspec.yaml`).

3. **Add permissions:**
   - Open `android/app/src/main/AndroidManifest.xml` and add the two
     `<uses-permission>` lines shown in
     `android/app/src/main/AndroidManifest_permissions_snippet.xml`
     (included in this project) inside the `<manifest>` tag.
   - Open `ios/Runner/Info.plist` and add the two keys shown in
     `ios/Info_plist_permissions_snippet.xml` inside the `<dict>` tag.

4. **Set minimum Android SDK** (ML Kit requires API 21+): in
   `android/app/build.gradle`, make sure:
   ```gradle
   minSdkVersion 21
   ```

5. **Install dependencies:**
   ```bash
   flutter pub get
   ```

6. **Run on a connected device:**
   ```bash
   flutter run
   ```

## Classroom demo script
1. Open app → tap **"Scan Document"**.
2. Tap **Camera** → take a photo of any printed page or notebook page.
3. Enter a title → tap **"Extract Text (OCR)"** → watch the real text
   appear in the text box, read straight from the photo.
4. Tap **"Save Document"** → you're back on the home list, showing the
   new entry with a thumbnail and text preview.
5. Tap the document → **"Export as PDF"** → share sheet opens showing a
   real generated PDF containing the image + extracted text.

## Possible future enhancements
- Automatic edge detection & perspective crop (like a real scanner)
- Multi-page scan → single combined PDF
- Full-text search across all saved documents
- Cloud backup/sync (Firebase) as an optional upgrade
- Handwriting recognition mode

## Viva talking points
- OCR runs **on-device** via Google ML Kit — no network call, no data
  leaves the phone, which is both a privacy and offline-reliability point.
- Local persistence uses SQLite (`sqflite`), giving you a real relational
  schema to describe (table: `documents`, columns, primary key, CRUD ops).
- PDF generation is done natively in Dart using the `pdf` package —
  you can explain how a PDF widget tree (`pw.Document`, `pw.MultiPage`)
  is composed and rendered to bytes.
- Architecture follows separation of concerns: `models/` (data),
  `services/` (business logic: DB, OCR, PDF), `screens/` (UI) — a simple
  but real layered architecture, not everything crammed into one file.
