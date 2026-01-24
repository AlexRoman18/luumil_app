import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luumil_app/services/cloudinary_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasosProductoScreen extends StatefulWidget {
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String categoria;
  final String subcategoria;
  final List<String> fotosProducto;

  const PasosProductoScreen({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.categoria,
    required this.subcategoria,
    required this.fotosProducto,
  });

  @override
  State<PasosProductoScreen> createState() => _PasosProductoScreenState();
}

class _PasosProductoScreenState extends State<PasosProductoScreen> {
  final List<PasoItem> _pasos = [PasoItem(numero: 1), PasoItem(numero: 2)];

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  void _agregarPaso() {
    setState(() {
      _pasos.add(PasoItem(numero: _pasos.length + 1));
    });
  }

  void _eliminarPaso(int index) {
    if (_pasos.length > 2) {
      setState(() {
        _pasos.removeAt(index);
        // Renumerar pasos
        for (int i = 0; i < _pasos.length; i++) {
          _pasos[i].numero = i + 1;
        }
      });
    }
  }

  Future<void> _seleccionarMultimedia(PasoItem paso) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería de fotos'),
              onTap: () async {
                Navigator.pop(context);
                final images = await _picker.pickMultiImage();
                if (images.isNotEmpty) {
                  setState(() {
                    paso.archivos.addAll(images.map((x) => File(x.path)));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () async {
                Navigator.pop(context);
                final image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() {
                    paso.archivos.add(File(image.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Grabar video'),
              onTap: () async {
                Navigator.pop(context);
                final video = await _picker.pickVideo(
                  source: ImageSource.camera,
                );
                if (video != null) {
                  setState(() {
                    paso.archivos.add(File(video.path));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarYSubir() async {
    setState(() => _isLoading = true);

    try {
      // Subir multimedia de cada paso
      List<Map<String, dynamic>> pasosList = [];

      for (var paso in _pasos) {
        // Solo agregar pasos que tengan descripción
        if (paso.controller.text.trim().isNotEmpty) {
          List<String> urlsMultimedia = [];

          for (var archivo in paso.archivos) {
            final url = await CloudinaryService.subirImagen(archivo);
            urlsMultimedia.add(url);
          }

          pasosList.add({
            'numero': paso.numero,
            'descripcion': paso.controller.text.trim(),
            'multimedia': urlsMultimedia,
          });
        }
      }

      // Guardar en Firebase
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': widget.nombre,
        'descripcion': widget.descripcion,
        'precio': widget.precio,
        'stock': widget.stock,
        'categoria': widget.categoria,
        'subcategoria': widget.subcategoria,
        'imagenes': widget.fotosProducto,
        'pasos': pasosList,
        'vendedorId': userId,
        'fecha': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto guardado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar pasos de elaboración'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Pasos de elaboración de "${widget.nombre}"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Describe cómo se elabora tu producto paso a paso. Puedes agregar fotos o videos opcionales.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Lista de pasos
                ..._pasos.asMap().entries.map((entry) {
                  int index = entry.key;
                  PasoItem paso = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF007BFF),
                                child: Text(
                                  '${paso.numero}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Paso ${paso.numero}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_pasos.length > 2)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _eliminarPaso(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: paso.controller,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Describe este paso... (opcional)',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Botón para agregar multimedia
                          OutlinedButton.icon(
                            onPressed: () => _seleccionarMultimedia(paso),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text(
                              'Agregar fotos/videos (opcional)',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF007BFF),
                            ),
                          ),

                          // Mostrar archivos seleccionados
                          if (paso.archivos.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: paso.archivos.map((archivo) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        archivo,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            paso.archivos.remove(archivo);
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

                // Botón para agregar más pasos
                OutlinedButton.icon(
                  onPressed: _agregarPaso,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar otro paso'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 30),

                // Botón guardar y subir
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardarYSubir,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Guardar y Subir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var paso in _pasos) {
      paso.controller.dispose();
    }
    super.dispose();
  }
}

class PasoItem {
  int numero;
  final TextEditingController controller = TextEditingController();
  final List<File> archivos = [];

  PasoItem({required this.numero});
}
