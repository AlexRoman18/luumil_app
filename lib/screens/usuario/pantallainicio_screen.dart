import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/widgets/usuario/mapa_ubicacion.dart';
import 'package:luumil_app/widgets/usuario/side_menu.dart';
import 'package:luumil_app/widgets/usuario/notification_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/screens/comer/detalle_producto_screen.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/services/carrito_service.dart';
import 'package:luumil_app/screens/usuario/carrito_screen.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final GlobalKey<State<MapaUbicacion>> _mapaKey =
      GlobalKey<State<MapaUbicacion>>();
  final TextEditingController _searchController = TextEditingController();
  final CarritoService _carritoService = CarritoService();

  @override
  void initState() {
    super.initState();
    _carritoService.addListener(_actualizarCarrito);
  }

  void _actualizarCarrito() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _carritoService.removeListener(_actualizarCarrito);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clave para controlar el Scaffold y abrir el Drawer
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,

      // 🔹 Drawer (menú lateral)
      drawer: const SideMenu(),

      // 🔹 AppBar superior
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {
            // 🔹 Abre el Drawer
            scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarritoScreen(),
                    ),
                  );
                },
              ),
              if (_carritoService.cantidadTotal > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_carritoService.cantidadTotal}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const NotificationBadge(),
          SizedBox(width: AppSpacing.sm),
        ],
      ),

      // 🔹 Contenido principal
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de bienvenida
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String nombre = 'Usuario';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    nombre = data['nombrePersonal'] ?? 'Usuario';
                  }

                  return Text(
                    '¡Bienvenido, $nombre!',
                    style: GoogleFonts.poppins(
                      fontSize: AppTypography.text3xl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.lg),

              // Barra de búsqueda
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textSecondary),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            final state = _mapaKey.currentState;
                            if (state != null && state is State) {
                              (state as dynamic).buscarComunidad(value.trim());
                            }
                          }
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          final state = _mapaKey.currentState;
                          if (state != null && state is State) {
                            (state as dynamic).buscarComunidad('');
                          }
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              MapaUbicacion(key: _mapaKey),
              const SizedBox(height: 20),

              // Sección de novedades
              Text(
                'Novedades',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Lista de productos de los vendedores
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('productos')
                    .orderBy('fecha', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: Text(
                          'No hay productos disponibles',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre = data['nombre'] ?? 'Sin nombre';
                      final precioData = data['precio'];
                      final precio = precioData is String
                          ? double.tryParse(precioData) ?? 0.0
                          : (precioData is num ? precioData.toDouble() : 0.0);
                      final fotos = data['fotos'] as List<dynamic>?;
                      final fotosProducto =
                          data['fotosProducto'] as List<dynamic>?;
                      final imagenes = data['imagenes'] as List<dynamic>?;
                      final vendedorId = data['vendedorId'] as String?;

                      // Buscar la primera imagen disponible en cualquier campo
                      String? imagenUrl;
                      if (fotos != null && fotos.isNotEmpty) {
                        imagenUrl = fotos[0];
                      } else if (fotosProducto != null &&
                          fotosProducto.isNotEmpty) {
                        imagenUrl = fotosProducto[0];
                      } else if (imagenes != null && imagenes.isNotEmpty) {
                        imagenUrl = imagenes[0];
                      }

                      return FutureBuilder<DocumentSnapshot>(
                        future: vendedorId != null
                            ? FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(vendedorId)
                                  .get()
                            : null,
                        builder: (context, vendedorSnapshot) {
                          String nombreTienda = 'Tienda';
                          String comunidadVendedor = 'Ubicación no disponible';

                          if (vendedorSnapshot.hasData &&
                              vendedorSnapshot.data!.exists) {
                            final vendedorData =
                                vendedorSnapshot.data!.data()
                                    as Map<String, dynamic>;
                            nombreTienda =
                                vendedorData['nombreTienda'] ?? 'Tienda';
                            comunidadVendedor =
                                vendedorData['comunidad'] ??
                                'Ubicación no disponible';
                          }

                          return GestureDetector(
                            onTap: () {
                              final productoCompleto = {
                                'id': doc.id,
                                ...data,
                                'nombreTienda': nombreTienda,
                                'comunidadVendedor': comunidadVendedor,
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalleProductoScreen(
                                    producto: productoCompleto,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        bottomLeft: Radius.circular(15),
                                      ),
                                    ),
                                    child: imagenUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft: Radius.circular(
                                                    15,
                                                  ),
                                                ),
                                            child: Image.network(
                                              imagenUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.black45,
                                                    );
                                                  },
                                            ),
                                          )
                                        : const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: Colors.black45,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          nombre,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${precio.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 12.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.black26,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        onPressed: () {
          context.push('/history-chat');
        },
        child: const Text(
          'IA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
