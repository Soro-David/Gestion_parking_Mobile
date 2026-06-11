import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class ImageCaptureWidget extends StatefulWidget {
  final String title;
  final ValueChanged<File>? onImageCaptured;

  const ImageCaptureWidget({
    super.key,
    required this.title,
    this.onImageCaptured,
  });

  @override
  State<ImageCaptureWidget> createState() => _ImageCaptureWidgetState();
}

class _ImageCaptureWidgetState extends State<ImageCaptureWidget> {
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final file = File(image.path);
        setState(() {
          _capturedImage = file;
        });
        if (widget.onImageCaptured != null) {
          widget.onImageCaptured!(file);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surface,
          content: Text('Erreur: $e', style: const TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.secondary,
              ),
              tooltip: 'Capturer une image',
            ),
          ],
        ),
        if (_capturedImage != null) ...[
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _capturedImage!,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}
