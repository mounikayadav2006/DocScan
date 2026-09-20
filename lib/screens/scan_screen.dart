import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/scanned_document.dart';
import '../services/database_helper.dart';
import '../services/ocr_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  File? _imageFile;
  bool _isProcessing = false;
  bool _hasExtracted = false;

  @override
  void dispose() {
    _ocrService.close();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _hasExtracted = false;
      _textController.clear();
      if (_titleController.text.isEmpty) {
        _titleController.text =
            'Document ${DateTime.now().toString().substring(0, 16)}';
      }
    });
  }

  Future<void> _runOcr() async {
    if (_imageFile == null) return;
    setState(() => _isProcessing = true);
    try {
      final text = await _ocrService.extractText(_imageFile!);
      setState(() {
        _textController.text = text;
        _hasExtracted = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR failed: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveDocument() async {
    if (_imageFile == null) return;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Copy the captured image into permanent app storage so it survives
    // even if the OS clears temporary cache used by the image picker.
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        'scan_${DateTime.now().millisecondsSinceEpoch}${_imageFile!.path.substring(_imageFile!.path.lastIndexOf('.'))}';
    final savedImage =
        await _imageFile!.copy('${appDir.path}/$fileName');

    final doc = ScannedDocument(
      title: _titleController.text.trim(),
      imagePath: savedImage.path,
      extractedText: _textController.text,
      createdAt: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertDocument(doc);

    setState(() => _isProcessing = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _captureImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _captureImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imageFile != null) ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Document Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _runOcr,
                icon: const Icon(Icons.text_snippet),
                label: Text(_hasExtracted
                    ? 'Re-run Text Extraction'
                    : 'Extract Text (OCR)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Extracted Text (editable)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _saveDocument,
                icon: const Icon(Icons.save),
                label: const Text('Save Document'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No image captured yet', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(_imageFile!, height: 260, fit: BoxFit.cover),
    );
  }
}
