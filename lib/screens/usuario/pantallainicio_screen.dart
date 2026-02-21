import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/widgets/usuario/mapa_ubicacion.dart';
import 'package:luumil_app/widgets/usuario/side_menu.dart';
import 'package:luumil_app/widgets/usuario/notification_badge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/screens/comer/detalle_producto_screen.dart';
import 'package:luumil_app/screens/usuario/referencias_pago_screen.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/widgets/usuario/pasos_modal.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State<MapaUbicacion>> _mapaKey =
      GlobalKey<State<MapaUbicacion>>();
  final TextEditingController _searchController = TextEditingController();
  String _nombreUsuario = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _nombreUsuario = doc.data()?['nombrePersonal'] ?? 'Usuario';
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.label_outline, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReferenciasPagoScreen(),
                ),
              );
            },
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
              Text(
                '¡Bienvenido, $_nombreUsuario!',
                style: GoogleFonts.poppins(
                  fontSize: AppTypography.text3xl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
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
                            if (state != null) {
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
                          if (state != null) {
                            (state as dynamic).buscarComunidad('');
                          }
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              MapaUbicacion(key: _mapaKey),
              const SizedBox(height: 20),

              // Sección de novedades
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Productos Destacados',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Mejor calificados',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Lista de productos mejor calificados (con caché)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('productos')
                    .where('promedioEstrellas', isGreaterThan: 0)
                    .orderBy('promedioEstrellas', descending: true)
                    .limit(8)
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
                      final promedioEstrellas =
                          (data['promedioEstrellas'] ?? 0.0).toDouble();
                      final totalLikes = data['totalLikes'] ?? 0;

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
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Imagen del producto
                                  Stack(
                                    children: [
                                      Container(
                                        width: 90,
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
                                                      topLeft: Radius.circular(
                                                        15,
                                                      ),
                                                      bottomLeft:
                                                          Radius.circular(15),
                                                    ),
                                                child: Image.network(
                                                  imagenUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return const Icon(
                                                          Icons
                                                              .image_not_supported,
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
                                      // Ícono de pasos (solo si tiene pasos)
                                      if (data['pasos'] != null &&
                                          (data['pasos'] as List).isNotEmpty)
                                        Positioned(
                                          top: 4,
                                          left: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    PasosModal(
                                                      pasos:
                                                          data['pasos']
                                                              as List<dynamic>,
                                                    ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF007BFF),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.info,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
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
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '\$${precio.toStringAsFixed(2)}',
                                                style: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF007BFF,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' /Kg',
                                                style: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF007BFF,
                                                  ).withValues(alpha: 0.6),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Estadísticas: Estrellas y Likes
                                        Row(
                                          children: [
                                            // Estrellas
                                            const Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              promedioEstrellas.toStringAsFixed(
                                                1,
                                              ),
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.amber[800],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Likes
                                            const Icon(
                                              Icons.favorite,
                                              size: 14,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$totalLikes',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
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
    );
  }
}
