import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Wraps Google ML Kit's on-device text recognizer.
///
/// This runs fully offline on the device (no internet/API call needed),
/// which is what lets the whole app work without a backend.
class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Takes a photo file and returns the recognized text as a single string.
  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await _recognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Call this when the OCR service is no longer needed (e.g. in dispose())
  /// to free native resources.
  void close() {
    _recognizer.close();
  }
}
