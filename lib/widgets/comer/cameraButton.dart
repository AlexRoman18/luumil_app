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
    // Pedir permiso de cámara
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se necesita permiso para usar la cámara'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Botón de cámara con ícono de cruz predeterminado
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: const Center(
              child: Icon(
                Icons.add_circle_outline, // 🔹 Ícono de cruz predeterminado
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 🔹 Vista previa de las imágenes tomadas
        if (_images.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _images
                .map(
                  (img) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      img,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
