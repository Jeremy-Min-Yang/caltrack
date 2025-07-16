import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/ocr_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _imageFile;
  String? _ocrText;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _ocrText = null;
      });
    }
  }

  Future<void> _extractText() async {
    if (_imageFile == null) return;
    setState(() {
      _isProcessing = true;
      _ocrText = null;
    });
    try {
      final text = await _ocrService.extractTextFromImage(_imageFile!.path);
      setState(() {
        _ocrText = text;
      });
    } catch (e) {
      setState(() {
        _ocrText = 'Failed to extract text: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Nutrition Label')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile != null)
                Image.file(_imageFile!, height: 250)
              else
                const Text('No image selected.'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_imageFile != null)
                ElevatedButton(
                  onPressed: _isProcessing ? null : _extractText,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Extract Text'),
                ),
              if (_ocrText != null) ...[
                const SizedBox(height: 24),
                const Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_ocrText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 