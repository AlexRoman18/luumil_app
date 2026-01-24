import 'dart:io';
import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/comer/custom_text_field.dart';
import 'package:luumil_app/widgets/comer/cameraButton.dart';
import 'package:luumil_app/widgets/comer/no-reutilizable/solicitud_button.dart';
import 'package:luumil_app/services/cloudinary_service.dart'; // 🔹 Importa tu servicio

class RegisterForm extends StatefulWidget {
  final double heightFactor;

  const RegisterForm({super.key, this.heightFactor = 0.7});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  List<String> imagenesUrls = [];
  bool _subiendoImagen = false; // Flag para evitar duplicados

  /// 🔹 Método para subir imagen a Cloudinary y guardar URL
  Future<void> _subirImagen(File imagen) async {
    if (_subiendoImagen) return; // Evitar duplicados

    setState(() => _subiendoImagen = true);

    try {
      final url = await CloudinaryService.subirImagen(imagen);
      if (mounted) {
        setState(() {
          imagenesUrls.add(url);
          _subiendoImagen = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Imagen subida correctamente")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _subiendoImagen = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al subir imagen: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: size.height * widget.heightFactor,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // 🔹 Nombre del negocio
                CustomTextField(
                  hint: 'Nombre del negocio',
                  icon: Icons.store,
                  controller: nombreController,
                ),
                const SizedBox(height: 14),

                // 🔹 Descripción corta
                CustomTextField(
                  hint: 'Descripción corta',
                  icon: Icons.description,
                  controller: descripcionController,
                ),
                const SizedBox(height: 18),

                const Text(
                  'Por favor, adjunte mínimo 3 imágenes que evidencien la existencia de sus ventas',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // 🔹 CameraButton conectado a Cloudinary
                CameraButton(
                  onImageCaptured: (File imagen) async {
                    await _subirImagen(imagen);
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 Botón principal (Enviar)
                Builder(
                  builder: (context) => SolicitudButton(
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    imagenes: imagenesUrls,
                    // Validación antes de enviar
                    onValidate: () {
                      if (nombreController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingrese el nombre del negocio'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return false;
                      }
                      if (descripcionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingrese la descripción'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return false;
                      }
                      if (imagenesUrls.length < 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Debe subir mínimo 3 imágenes'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return false;
                      }
                      return true;
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
