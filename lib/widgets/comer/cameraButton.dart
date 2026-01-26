import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraButton extends StatefulWidget {
  final bool showBorder;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;

  // 👇 propiedad para el callback
  final ValueChanged<File>? onImageCaptured;

  const CameraButton({
    super.key,
    this.showBorder = true,
    this.backgroundColor = const Color(0xFFF2F2F2),
    this.iconColor = Colors.grey,
    this.borderColor = const Color(0xFFBDBDBD),
    this.onImageCaptured, // 👈 ahora opcional
  });

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton> {
  final List<File> _images = [];

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null && mounted) {
        final file = File(image.path);

        setState(() {
          _images.add(file);
        });

        // 👇 aquí notificamos al padre
        widget.onImageCaptured?.call(file);
      }
    } else if (status.isDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesita permiso para usar la cámara'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: widget.showBorder
            ? Border.all(color: widget.borderColor, width: 2)
            : null, // 👈 ahora sí respeta showBorder
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final img in _images)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  img,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: widget.showBorder
                      ? Border.all(color: widget.borderColor, width: 2)
                      : null, // 👈 también aquí
                ),
                child: Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: widget.iconColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
