import 'dart:io';
import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/comer/cameraButton.dart';
import 'package:luumil_app/services/cloudinary_service.dart';
import 'package:luumil_app/screens/comer/pasos_producto_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NuevoProductoPage extends StatefulWidget {
  const NuevoProductoPage({super.key});

  @override
  State<NuevoProductoPage> createState() => _NuevoProductoPageState();
}

class _NuevoProductoPageState extends State<NuevoProductoPage> {
  Key _cameraKey = UniqueKey();

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final stockController = TextEditingController();

  String? categoriaSeleccionada;
  String? subcategoriaSeleccionada;
  final List<File> _imagenesSeleccionadas = [];

  final formKey = GlobalKey<FormState>();

  final categorias = [
    'Dulces',
    'Verduras',
    'Frutas',
    'Limpieza',
    'Zapatos',
    'Otros',
  ];

  // Mapa de subcategorías por categoría
  final Map<String, List<String>> subcategorias = {
    'Dulces': ['Chocolate', 'Caramelos', 'Gomitas', 'Paletas', 'Otros dulces'],
    'Verduras': [
      'Hojas verdes',
      'Raíces',
      'Tubérculos',
      'Chiles',
      'Otras verduras',
    ],
    'Frutas': [
      'Cítricos',
      'Tropicales',
      'Berries',
      'Frutas de temporada',
      'Otras frutas',
    ],
    'Limpieza': [
      'Jabones',
      'Detergentes',
      'Desinfectantes',
      'Utensilios',
      'Otros',
    ],
    'Zapatos': ['Tradicionales', 'Deportivos', 'Casual', 'Sandalias', 'Otros'],
    'Otros': ['Artesanías', 'Textiles', 'Joyería', 'Decoración', 'Otros'],
  };

  List<String> get subcategoriasDisponibles {
    if (categoriaSeleccionada == null) return [];
    return subcategorias[categoriaSeleccionada] ?? [];
  }

  InputDecoration fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget photoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Icon(Icons.camera_alt, size: 50),
          const SizedBox(height: 10),
          const Text(
            'Añadir fotos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CameraButton(
            key: _cameraKey,
            backgroundColor: const Color(0xFFE3F2FD),
            iconColor: const Color.fromRGBO(33, 150, 243, 1),
            showBorder: true,
            borderColor: Colors.grey,
            onImageCaptured: (File imagen) {
              setState(() => _imagenesSeleccionadas.add(imagen));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Nuevo producto',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nombre del producto'),
              TextFormField(
                controller: nombreController,
                decoration: fieldDecoration('Ej: Tomates Cherry'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 15),

              const Text('Descripción del producto'),
              TextFormField(
                controller: descripcionController,
                maxLines: 3,
                decoration: fieldDecoration('Describe tu producto'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese la descripción' : null,
              ),
              const SizedBox(height: 15),

              const Text('Precio'),
              TextFormField(
                controller: precioController,
                keyboardType: TextInputType.number,
                decoration: fieldDecoration('\$ 0.00'),
                validator: (v) {
                  final parsed = double.tryParse(v ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Precio inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 👇 Aquí agregas el campo de stock
              const Text('Stock disponible'),
              TextFormField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: fieldDecoration('Ej: 10'),
                validator: (v) {
                  final parsed = int.tryParse(v ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              const Text('Categoría'),
              DropdownButtonFormField<String>(
                initialValue: categoriaSeleccionada,
                decoration: fieldDecoration('Selecciona categoría'),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() {
                  categoriaSeleccionada = v;
                  subcategoriaSeleccionada = null; // Resetear subcategoría
                }),
                validator: (v) => v == null ? 'Seleccione categoría' : null,
              ),
              const SizedBox(height: 15),

              // Subcategoría (solo si hay categoría seleccionada)
              if (categoriaSeleccionada != null) ...[
                const Text('Subcategoría'),
                DropdownButtonFormField<String>(
                  initialValue: subcategoriaSeleccionada,
                  decoration: fieldDecoration('Selecciona subcategoría'),
                  items: subcategoriasDisponibles
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => subcategoriaSeleccionada = v),
                  validator: (v) =>
                      v == null ? 'Seleccione subcategoría' : null,
                ),
                const SizedBox(height: 15),
              ],

              photoCard(),
              const SizedBox(height: 30),

              // Botón para continuar a pasos
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (_imagenesSeleccionadas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Debe tomar al menos una foto'),
                          ),
                        );
                        return;
                      }

                      // Mostrar indicador de carga
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        // Subir imágenes del producto a Cloudinary
                        final urls = <String>[];
                        for (final img in _imagenesSeleccionadas) {
                          final url = await CloudinaryService.subirImagen(img);
                          urls.add(url);
                        }

                        // Cerrar indicador de carga
                        if (context.mounted) Navigator.pop(context);

                        // Navegar a pantalla de pasos
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PasosProductoScreen(
                                nombre: nombreController.text.trim(),
                                descripcion: descripcionController.text.trim(),
                                precio: double.parse(
                                  precioController.text.trim().replaceAll(
                                    ',',
                                    '.',
                                  ),
                                ),
                                stock: int.parse(stockController.text.trim()),
                                categoria: categoriaSeleccionada!,
                                subcategoria: subcategoriaSeleccionada!,
                                fotosProducto: urls,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        // Cerrar indicador de carga
                        if (context.mounted) Navigator.pop(context);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al subir imágenes: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                  ),
                  child: const Text(
                    'Agregar pasos de elaboración →',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón para guardar sin pasos
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (_imagenesSeleccionadas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Debe tomar al menos una foto'),
                          ),
                        );
                        return;
                      }

                      // Mostrar indicador de carga
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        // Subir imágenes del producto a Cloudinary
                        final urls = <String>[];
                        for (final img in _imagenesSeleccionadas) {
                          final url = await CloudinaryService.subirImagen(img);
                          urls.add(url);
                        }

                        // Guardar directamente en Firebase sin pasos
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        await FirebaseFirestore.instance
                            .collection('productos')
                            .add({
                              'nombre': nombreController.text.trim(),
                              'descripcion': descripcionController.text.trim(),
                              'precio': double.parse(
                                precioController.text.trim().replaceAll(
                                  ',',
                                  '.',
                                ),
                              ),
                              'stock': int.parse(stockController.text.trim()),
                              'categoria': categoriaSeleccionada,
                              'subcategoria': subcategoriaSeleccionada,
                              'imagenes': urls,
                              'pasos': [], // Sin pasos
                              'vendedorId': userId,
                              'fecha': FieldValue.serverTimestamp(),
                            });

                        // Cerrar indicador de carga
                        if (context.mounted) Navigator.pop(context);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Producto guardado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Limpiar formulario
                          nombreController.clear();
                          descripcionController.clear();
                          precioController.clear();
                          stockController.clear();
                          setState(() {
                            categoriaSeleccionada = null;
                            subcategoriaSeleccionada = null;
                            _imagenesSeleccionadas.clear();
                            _cameraKey = UniqueKey();
                          });
                        }
                      } catch (e) {
                        // Cerrar indicador de carga
                        if (context.mounted) Navigator.pop(context);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromRGBO(33, 150, 243, 1),
                    ),
                  ),
                  child: const Text(
                    'Guardar sin pasos',
                    style: TextStyle(
                      color: Color.fromRGBO(33, 150, 243, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    stockController.dispose();
    super.dispose();
  }
}
