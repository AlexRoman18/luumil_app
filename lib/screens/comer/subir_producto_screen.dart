import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/widgets/comer/cameraButton.dart';

class NuevoProductoPage extends StatefulWidget {
  const NuevoProductoPage({super.key});

  @override
  State<NuevoProductoPage> createState() => _NuevoProductoPageState();
}

class _NuevoProductoPageState extends State<NuevoProductoPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  String? categoriaSeleccionada;

  final List<File> _imagenesSeleccionadas = []; // 👈 lista de fotos

  final List<String> categorias = [
    'Frutas',
    'Limpieza',
    'Joyería',
    'Verduras',
    'Otros',
  ];

  final formKey = GlobalKey<FormState>();

  // 👇 función para subir una foto a Firebase Storage
  Future<String> subirFoto(File imagen) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('productos')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(imagen);
    final url = await ref.getDownloadURL();
    print('✅ Foto subida: $url');
    return url;
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 50, color: Colors.black87),
          const SizedBox(height: 10),
          const Text(
            'Añadir fotos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text(
            'Muestra tu producto desde diferentes ángulos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 10),
          CameraButton(
            backgroundColor: const Color(0xFFE3F2FD),
            iconColor: const Color.fromRGBO(33, 150, 243, 1),
            showBorder: true,
            borderColor: Colors.grey,
            onImageCaptured: (File imagen) {
              setState(() {
                _imagenesSeleccionadas.add(imagen);
              });
              print(
                '✅ Imagen añadida a la lista en NuevoProductoPage: ${imagen.path}',
              );
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
        title: const Text(
          'Nuevo producto',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombre del producto',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: nombreController,
                decoration: fieldDecoration('Ej: Tomates Cherry'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 15),
              const Text(
                'Descripción del producto',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: descripcionController,
                maxLines: 3,
                decoration: fieldDecoration('Describe a detalle tu producto'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Ingrese la descripción'
                    : null,
              ),
              const SizedBox(height: 15),
              const Text(
                'Precio',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: fieldDecoration('\$ 0.00'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese el precio';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null) return 'Precio inválido';
                  if (parsed < 0) return 'El precio no puede ser negativo';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text(
                'Categoría',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: categoriaSeleccionada,
                hint: const Text('Seleccione la categoría del producto'),
                isExpanded: true,
                decoration: fieldDecoration(''),
                items: categorias
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => categoriaSeleccionada = value),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Seleccione categoría' : null,
              ),
              const SizedBox(height: 25),
              const Text(
                'Fotos',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 10),
              photoCard(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      try {
                        print('🟡 Iniciando guardado de producto...');
                        final urls = <String>[];
                        for (final img in _imagenesSeleccionadas) {
                          final url = await subirFoto(img);
                          urls.add(url);
                        }

                        final producto = {
                          'nombre': nombreController.text.trim(),
                          'descripcion': descripcionController.text.trim(),
                          'precio': double.parse(
                            precioController.text.trim().replaceAll(',', '.'),
                          ),
                          'categoria': categoriaSeleccionada,
                          'fotos': urls,
                          'fecha': FieldValue.serverTimestamp(),
                        };

                        print('🟢 Datos a guardar: $producto');

                        await FirebaseFirestore.instance
                            .collection('productos')
                            .add(producto);

                        print('✅ Producto guardado en Firestore');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Producto guardado en Firebase'),
                          ),
                        );
                      } catch (e) {
                        print('🔴 Error al guardar: $e');
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar y subir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 👈 aquí se fuerza el color blanco
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
    super.dispose();
  }
}
