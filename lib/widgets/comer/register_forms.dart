import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/widgets/comer/custom_text_field.dart';
import 'package:luumil_app/widgets/comer/cameraButton.dart';
import 'package:luumil_app/widgets/comer/no-reutilizable/solicitud_button.dart';
import 'package:luumil_app/services/cloudinary_service.dart'; // 🔹 Importa tu servicio
import 'package:luumil_app/widgets/usuario/seleccionar_ubicacion_mapa.dart';

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
  LatLng? _ubicacionSeleccionada;
  String _textoUbicacion = 'Seleccionar ubicación';
  bool _ubicacionCargada = false;

  @override
  void initState() {
    super.initState();
    _cargarUbicacionUsuario();
  }

  /// 🔹 Cargar ubicación GPS del usuario si ya la tiene guardada
  Future<void> _cargarUbicacionUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data();
          final ubicacion = data?['ubicacion'] as Map<String, dynamic>?;

          if (ubicacion != null &&
              ubicacion['latitude'] != null &&
              ubicacion['longitude'] != null) {
            setState(() {
              _ubicacionSeleccionada = LatLng(
                ubicacion['latitude'],
                ubicacion['longitude'],
              );
              _textoUbicacion = 'Ubicación actual';
              _ubicacionCargada = true;
            });
          }
        }
      }
    } catch (e) {
      // Si hay error, simplemente no carga ubicación previa
    }
  }

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

  /// 🔹 Método para seleccionar ubicación en el mapa
  Future<void> _seleccionarUbicacion() async {
    final ubicacion = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SeleccionarUbicacionMapa(ubicacionInicial: _ubicacionSeleccionada),
      ),
    );

    if (ubicacion != null && mounted) {
      setState(() {
        _ubicacionSeleccionada = ubicacion;
        _textoUbicacion = 'Ubicación seleccionada';
        _ubicacionCargada = false; // Ya no es la precargada, es nueva
      });
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

                // 🔹 Botón de ubicación
                GestureDetector(
                  onTap: _seleccionarUbicacion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _ubicacionSeleccionada != null
                          ? const Color(0xFF007BFF).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _ubicacionSeleccionada != null
                            ? const Color(0xFF007BFF)
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _ubicacionSeleccionada != null
                              ? const Color(0xFF007BFF)
                              : Colors.grey[600],
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _textoUbicacion,
                            style: TextStyle(
                              fontSize: 15,
                              color: _ubicacionSeleccionada != null
                                  ? const Color(0xFF007BFF)
                                  : Colors.grey[700],
                              fontWeight: _ubicacionSeleccionada != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_ubicacionCargada)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Precargada',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                // Advertencia sobre ubicación GPS
                if (_ubicacionSeleccionada == null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Es obligatorio seleccionar tu ubicación GPS para que los clientes puedan encontrarte en el mapa',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[900],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    ubicacion: _ubicacionSeleccionada,
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
                      if (_ubicacionSeleccionada == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              '📍 Para aparecer en el mapa, debes seleccionar tu ubicación GPS precisa',
                            ),
                            backgroundColor: Colors.orange[700],
                            duration: const Duration(seconds: 4),
                            action: SnackBarAction(
                              label: 'Seleccionar',
                              textColor: Colors.white,
                              onPressed: () {
                                _seleccionarUbicacion();
                              },
                            ),
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
