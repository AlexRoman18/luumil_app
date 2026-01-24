import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luumil_app/services/cloudinary_service.dart';
import 'dart:io';

class EditarProductoScreen extends StatefulWidget {
  final String productoId;
  final Map<String, dynamic> producto;

  const EditarProductoScreen({
    super.key,
    required this.productoId,
    required this.producto,
  });

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<String> _imagenesUrls = [];
  bool _guardando = false;

  final List<String> _categorias = [
    'Dulces',
    'Verduras',
    'Frutas',
    'Limpieza',
    'Zapatos',
    'Otros',
  ];
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.producto['nombre'] ?? '';
    _precioController.text = widget.producto['precio']?.toString() ?? '';
    _descripcionController.text = widget.producto['descripcion'] ?? '';

    // Validar que la categoría exista en la lista
    final categoriaGuardada = widget.producto['categoria'] as String?;
    if (categoriaGuardada != null && _categorias.contains(categoriaGuardada)) {
      _categoriaSeleccionada = categoriaGuardada;
    } else {
      // Si no existe, intentar normalizar (ej: "Verduras" -> "Verdura")
      final categoriaNormalizada = _categorias.firstWhere(
        (cat) => cat.toLowerCase().startsWith(
          categoriaGuardada?.toLowerCase() ?? '',
        ),
        orElse: () => _categorias[0],
      );
      _categoriaSeleccionada = categoriaNormalizada;
    }

    _imagenesUrls = List<String>.from(widget.producto['imagenes'] ?? []);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _agregarImagen() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _guardando = true);

      final url = await CloudinaryService.subirImagen(File(image.path));

      setState(() {
        _imagenesUrls.add(url);
        _guardando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Imagen agregada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _eliminarImagen(int index) {
    setState(() {
      _imagenesUrls.removeAt(index);
    });
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagenesUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe tener al menos una imagen'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await FirebaseFirestore.instance
          .collection('productos')
          .doc(widget.productoId)
          .update({
            'nombre': _nombreController.text.trim(),
            'precio': _precioController.text.trim(),
            'descripcion': _descripcionController.text.trim(),
            'categoria': _categoriaSeleccionada,
            'imagenes': _imagenesUrls,
            'fechaActualizacion': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Retornar true para indicar que se guardó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Producto',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de imágenes
              _buildSeccionTitulo('Imágenes', Icons.photo_library),
              const SizedBox(height: 12),
              _buildGaleriaImagenes(),

              const SizedBox(height: 28),

              // Información del producto
              _buildSeccionTitulo('Información', Icons.info_outline),
              const SizedBox(height: 16),

              _buildCampoTexto(
                controller: _nombreController,
                label: 'Nombre del producto',
                icono: Icons.shopping_bag_outlined,
                hint: 'Ej: Pan integral artesanal',
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildCampoTexto(
                      controller: _precioController,
                      label: 'Precio',
                      icono: Icons.attach_money,
                      hint: '0.00',
                      teclado: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildDropdownCategoria()),
                ],
              ),

              const SizedBox(height: 16),

              _buildCampoTexto(
                controller: _descripcionController,
                label: 'Descripción',
                icono: Icons.description_outlined,
                hint: 'Describe tu producto en detalle...',
                maxLineas: 5,
              ),

              const SizedBox(height: 32),

              // Botón guardar
              _buildBotonGuardar(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo, IconData icono) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF007BFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: const Color(0xFF007BFF), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGaleriaImagenes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_imagenesUrls.length} ${_imagenesUrls.length == 1 ? 'imagen' : 'imágenes'}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_imagenesUrls.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Mínimo 1 imagen',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Botón agregar imagen (primero)
                _buildBotonAgregarImagen(),
                const SizedBox(width: 12),
                // Imágenes existentes
                ..._imagenesUrls.asMap().entries.map((entry) {
                  final index = entry.key;
                  final url = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildImagenItem(url, index),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonAgregarImagen() {
    return GestureDetector(
      onTap: _guardando ? null : _agregarImagen,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF007BFF).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF007BFF).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF007BFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate,
                size: 32,
                color: Color(0xFF007BFF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar foto',
              style: GoogleFonts.poppins(
                color: const Color(0xFF007BFF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenItem(String url, int index) {
    return Stack(
      children: [
        Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
        // Botón eliminar
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _mostrarConfirmacionEliminar(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
        // Indicador de imagen principal
        if (index == 0)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Principal',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _mostrarConfirmacionEliminar(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Eliminar imagen?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarImagen(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    String? hint,
    int maxLineas = 1,
    TextInputType? teclado,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLineas,
        keyboardType: teclado,
        style: GoogleFonts.poppins(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: Icon(icono, color: const Color(0xFF007BFF), size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLineas > 1 ? 16 : 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownCategoria() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _categoriaSeleccionada,
        decoration: InputDecoration(
          labelText: 'Categoría',
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          prefixIcon: const Icon(
            Icons.category_outlined,
            color: Color(0xFF007BFF),
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
        items: _categorias.map((categoria) {
          return DropdownMenuItem(value: categoria, child: Text(categoria));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _categoriaSeleccionada = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Seleccione una categoría';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007BFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _guardando ? null : _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _guardando
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Guardar Cambios',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
