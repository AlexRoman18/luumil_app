import 'dart:io';
import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/comer/cameraButton.dart';
import 'package:luumil_app/services/cloudinary_service.dart';
import 'package:luumil_app/services/firebase_product_service.dart';

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

  Future<void> guardarProducto() async {
    final urls = <String>[];

    for (final img in _imagenesSeleccionadas) {
      final url = await CloudinaryService.subirImagen(img);
      urls.add(url);
    }

    await FirebaseProductoService.guardarProducto(
      nombre: nombreController.text.trim(),
      descripcion: descripcionController.text.trim(),
      precio: double.parse(precioController.text.trim().replaceAll(',', '.')),
      categoria: categoriaSeleccionada ?? 'Otros',
      fotos: urls,
      stock: int.parse(stockController.text.trim()),
    );

    setState(() {
      nombreController.clear();
      descripcionController.clear();
      precioController.clear();
      stockController.clear();
      categoriaSeleccionada = null;
      _imagenesSeleccionadas.clear();
      _cameraKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuevo producto',
          style: TextStyle(color: Colors.black),
        ),
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
                value: categoriaSeleccionada,
                decoration: fieldDecoration('Categoría'),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => categoriaSeleccionada = v),
                validator: (v) => v == null ? 'Seleccione categoría' : null,
              ),
              const SizedBox(height: 25),

              photoCard(),
              const SizedBox(height: 30),

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
                        return; // 👈 Detiene el flujo si no hay fotos
                      }

                      await guardarProducto();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto guardado correctamente'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                  ),
                  child: const Text(
                    'Guardar y subir',
                    style: TextStyle(color: Colors.white),
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
