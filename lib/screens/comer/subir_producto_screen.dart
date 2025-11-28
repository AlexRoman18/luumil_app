import 'package:flutter/material.dart';

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

  final List<String> categorias = [
    'Frutas',
    'Limpieza',
    'Joyería',
    'Verduras',
    'Otros',
  ];

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    InputDecoration fieldDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      );
    }

    Widget photoCard() {
      return GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blueAccent, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
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
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blueAccent),
                ),
                child: const Text('Subir fotos'),
              ),
            ],
          ),
        ),
      );
    }

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
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese el nombre';
                  return null;
                },
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
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Ingrese la descripción';
                  return null;
                },
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
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      // TODO: lógica para guardar y subir el producto
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Guardando producto...')),
                      );
                    } else {
                      // opción: mostrar errores
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar y subir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      //color: Colors.white, // 👈 AQUÍ
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
