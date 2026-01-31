import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey[400],
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget photoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2196F3).withOpacity(0.1),
            const Color(0xFF2196F3).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 28,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Añadir fotos del producto',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _imagenesSeleccionadas.isEmpty
                      ? 'Toma fotos de tu producto'
                      : '${_imagenesSeleccionadas.length} foto${_imagenesSeleccionadas.length > 1 ? "s" : ""} seleccionada${_imagenesSeleccionadas.length > 1 ? "s" : ""}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          CameraButton(
            key: _cameraKey,
            backgroundColor: Colors.transparent,
            iconColor: const Color(0xFF2196F3),
            showBorder: false,
            borderColor: Colors.transparent,
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
        title: Text(
          'Nuevo producto',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre del producto',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nombreController,
                decoration: fieldDecoration('Ej: Tomates Cherry'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 20),

              Text(
                'Descripción del producto',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descripcionController,
                maxLines: 3,
                decoration: fieldDecoration('Describe tu producto'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese la descripción' : null,
              ),
              const SizedBox(height: 20),

              Text(
                'Precio',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 20),

              Text(
                'Stock disponible',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
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

              const SizedBox(height: 20),

              Text(
                'Categoría',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
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
                Text(
                  'Subcategoría',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
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
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: const Color(0xFF2196F3).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Agregar pasos de elaboración',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
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
                    side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Guardar sin pasos',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2196F3),
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
