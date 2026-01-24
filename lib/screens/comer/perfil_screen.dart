import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/widgets/comer/perfil_header.dart';
import 'package:luumil_app/widgets/comer/perfil_section.dart';
import 'package:luumil_app/widgets/comer/perfil_header_background.dart';
import 'package:luumil_app/services/vendor_service.dart';
import 'package:luumil_app/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final VendorService _vendorService = VendorService();
  final ImagePicker _picker = ImagePicker();

  String? _fotoPerfil;
  String _nombre = '';
  String _descripcion = '';
  bool _cargando = true;

  final TextEditingController _historiaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final perfil = await _vendorService.getPerfilVendedor();
    if (perfil != null && mounted) {
      setState(() {
        _fotoPerfil = perfil['fotoPerfil'];
        _nombre = perfil['nombre'] ?? 'Vendedor';
        _descripcion = perfil['descripcion'] ?? 'Descripción del negocio';
        _historiaController.text = perfil['historia'] ?? 'Nuestra historia...';
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarFotoPerfil() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () async {
                Navigator.pop(context);
                await _seleccionarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de Galería'),
              onTap: () async {
                Navigator.pop(context);
                await _seleccionarImagen(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      final url = await CloudinaryService.subirImagen(File(image.path));

      final exito = await _vendorService.actualizarPerfil(fotoPerfil: url);

      if (exito && mounted) {
        setState(() => _fotoPerfil = url);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _historiaController.dispose();
    super.dispose();
  }

  Future<void> _editarCampo(String campo, String valorActual) async {
    final controller = TextEditingController(text: valorActual);

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $campo'),
        content: TextField(
          controller: controller,
          maxLines: campo == 'Descripción' ? 3 : 1,
          decoration: InputDecoration(hintText: 'Ingrese $campo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null && resultado.isNotEmpty) {
      bool exito = false;

      if (campo == 'Nombre') {
        exito = await _vendorService.actualizarPerfil(nombre: resultado);
        if (exito) setState(() => _nombre = resultado);
      } else if (campo == 'Descripción') {
        exito = await _vendorService.actualizarPerfil(descripcion: resultado);
        if (exito) setState(() => _descripcion = resultado);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exito ? '✅ $campo actualizado' : '❌ Error'),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PerfilHeaderBackground(),

            ProfileHeader(
              fotoPerfil: _fotoPerfil,
              nombre: _nombre,
              descripcion: _descripcion,
              onEditFoto: _cambiarFotoPerfil,
              onEditNombre: () => _editarCampo('Nombre', _nombre),
              onEditDescripcion: () =>
                  _editarCampo('Descripción', _descripcion),
            ),

            // 🏷️ Nuestra Historia (Editable)
            GestureDetector(
              onTap: () {
                _editarHistoria();
              },
              child: ProfileSection(
                title: 'Nuestra Historia',
                icon: Icons.edit_outlined,
                content: _historiaController.text,
              ),
            ),

            // 📰 Mis Productos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mis Productos",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  StreamBuilder<QuerySnapshot>(
                    stream: _vendorService.getMisProductos(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          child: const Center(
                            child: Text('No tienes productos publicados'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final producto = snapshot.data!.docs[index];
                          final data = producto.data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              leading:
                                  data['imagenes'] != null &&
                                      (data['imagenes'] as List).isNotEmpty
                                  ? Image.network(
                                      data['imagenes'][0],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    ),
                              title: Text(
                                data['nombre'] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('\$${data['precio'] ?? 0}'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _eliminarProducto(producto.id),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarHistoria() async {
    final controller = TextEditingController(text: _historiaController.text);

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Historia'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Cuéntanos la historia de tu negocio',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null && resultado.isNotEmpty) {
      final exito = await _vendorService.actualizarPerfil(historia: resultado);

      if (exito) {
        setState(() => _historiaController.text = resultado);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Historia actualizada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al actualizar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarProducto(String productoId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final exito = await _vendorService.eliminarProducto(productoId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exito ? '✅ Producto eliminado' : '❌ Error al eliminar',
            ),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
