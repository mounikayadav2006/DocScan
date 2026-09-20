import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/scanned_document.dart';

/// Builds a one-page PDF containing the scanned image and the OCR-extracted
/// text underneath it, then saves it into the app's documents directory.
class PdfService {
  Future<File> generatePdf(ScannedDocument doc) async {
    final pdf = pw.Document();
    final imageFile = File(doc.imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: doc.title),
          pw.SizedBox(height: 12),
          pw.Image(image, height: 260, fit: pw.BoxFit.contain),
          pw.SizedBox(height: 16),
          pw.Text(
            'Extracted Text:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            doc.extractedText.isEmpty
                ? '(No text detected)'
                : doc.extractedText,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeTitle = doc.title.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${dir.path}/$safeTitle.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
