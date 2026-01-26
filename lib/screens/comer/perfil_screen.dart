import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/widgets/comer/perfil_header.dart';
import 'package:luumil_app/widgets/comer/perfil_section.dart';
import 'package:luumil_app/widgets/comer/perfil_header_background.dart';
import 'package:luumil_app/services/vendor_service.dart';
import 'package:luumil_app/services/cloudinary_service.dart';
import 'package:luumil_app/screens/comer/detalle_producto_screen.dart';
import 'package:luumil_app/screens/comer/editar_producto_screen.dart';
import 'package:luumil_app/auth/auth_service.dart';
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
  final AuthService _authService = AuthService();
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
        _nombre = perfil['nombreTienda'] ?? 'Vendedor';
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
        exito = await _vendorService.actualizarPerfil(nombreTienda: resultado);
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                      const SizedBox(height: 16),

                      StreamBuilder<QuerySnapshot>(
                        stream: _vendorService.getMisProductos(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
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
                              final data =
                                  producto.data() as Map<String, dynamic>;
                              final imagenes = data['imagenes'] as List? ?? [];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
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
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetalleProductoScreen(
                                                producto: data,
                                              ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Imagen con indicador de múltiples fotos
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: imagenes.isNotEmpty
                                                    ? Image.network(
                                                        imagenes[0],
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                width: 100,
                                                                height: 100,
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                    colors: [
                                                                      Colors
                                                                          .grey[200]!,
                                                                      Colors
                                                                          .grey[300]!,
                                                                    ],
                                                                  ),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .broken_image_rounded,
                                                                  color: Colors
                                                                      .grey[400],
                                                                  size: 32,
                                                                ),
                                                              );
                                                            },
                                                      )
                                                    : Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              Colors.grey[200]!,
                                                              Colors.grey[300]!,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.image_rounded,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 32,
                                                        ),
                                                      ),
                                              ),
                                              // Indicador de múltiples imágenes
                                              if (imagenes.length > 1)
                                                Positioned(
                                                  top: 6,
                                                  right: 6,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.75),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .collections_rounded,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          '${imagenes.length}',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 14),
                                          // Información del producto
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['nombre'] ??
                                                      'Sin nombre',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF007BFF),
                                                            Color(0xFF0056D2),
                                                          ],
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '\$${data['precio'] ?? 0}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                if (data['categoria'] !=
                                                    null) ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.category_rounded,
                                                        size: 14,
                                                        color: Colors.grey[500],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        data['categoria'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Botones de acción
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF007BFF,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_rounded,
                                                    color: Color(0xFF007BFF),
                                                    size: 22,
                                                  ),
                                                  onPressed: () async {
                                                    final resultado =
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditarProductoScreen(
                                                                  productoId:
                                                                      producto
                                                                          .id,
                                                                  producto:
                                                                      data,
                                                                ),
                                                          ),
                                                        );
                                                    if (resultado == true &&
                                                        mounted) {
                                                      setState(() {});
                                                    }
                                                  },
                                                  tooltip: 'Editar',
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(
                                                    0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_rounded,
                                                    color: Colors.red,
                                                    size: 22,
                                                  ),
                                                  onPressed: () =>
                                                      _eliminarProducto(
                                                        producto.id,
                                                      ),
                                                  tooltip: 'Eliminar',
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
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

          // Botón flotante de cerrar sesión
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _cerrarSesion,
            ),
          ),
        ],
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

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authService.signOut();
      if (mounted) {
        // Eliminar todas las rutas y volver al home
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }
  }
}
