import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraButton extends StatefulWidget {
  const CameraButton({super.key});

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
        setState(() {
          _images.add(File(image.path));
        });
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
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      // 👉 Altura mínima, pero deja que crezca si hay muchas fotos
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.98 * 255).round()),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.onSurface.withAlpha((0.12 * 255).round()),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          // 👇 Cambia esto:
          alignment: WrapAlignment.center, // antes: start
          runAlignment: WrapAlignment.center, // para centrar también las filas
          spacing: 8,
          runSpacing: 8,
          children: [
            // fotos
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

            // botón con la cruz
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha(
                    (0.95 * 255).round(),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.12 * 255).round(),
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.7 * 255).round(),
                    ),
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
