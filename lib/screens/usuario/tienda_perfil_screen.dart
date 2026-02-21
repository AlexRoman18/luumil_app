import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luumil_app/services/vendedor_service.dart';
import 'package:luumil_app/screens/usuario/chat_screen.dart';
import '../comer/detalle_producto_screen.dart';

class TiendaPerfilScreen extends StatefulWidget {
  final String vendedorId;

  const TiendaPerfilScreen({super.key, required this.vendedorId});

  @override
  State<TiendaPerfilScreen> createState() => _TiendaPerfilScreenState();
}

class _TiendaPerfilScreenState extends State<TiendaPerfilScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VendedorService _vendedorService = VendedorService();

  bool _cargando = true;
  bool _estaSiguiendo = false;
  bool _cargandoSeguir = true;
  String _nombreTienda = '';
  String _descripcion = '';
  String _comunidad = '';
  String _historia = '';
  String? _fotoPerfil;
  int _seguidores = 0;
  List<Map<String, dynamic>> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosTienda();
    _cargarProductos();
    _verificarSeguimiento();
  }

  Future<void> _verificarSeguimiento() async {
    final siguiendo = await _vendedorService.estaSiguiendo(widget.vendedorId);
    if (mounted) {
      setState(() {
        _estaSiguiendo = siguiendo;
        _cargandoSeguir = false;
      });
    }
  }

  Future<void> _toggleSeguir() async {
    setState(() => _cargandoSeguir = true);
    await _vendedorService.toggleSeguir(widget.vendedorId);
    await _verificarSeguimiento();
    await _cargarDatosTienda(); // Recargar para actualizar contador
  }

  Future<void> _cargarDatosTienda() async {
    try {
      final doc = await _firestore
          .collection('usuarios')
          .doc(widget.vendedorId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _nombreTienda =
              data['nombreTienda'] ?? data['nombrePersonal'] ?? 'Tienda';
          _descripcion = data['descripcion'] ?? '';
          _comunidad = data['comunidad'] ?? 'Sin ubicación';
          _historia = data['historia'] ?? '';
          _fotoPerfil = data['fotoPerfil'];
          _seguidores = data['seguidores'] ?? 0;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cargarProductos() async {
    try {
      final snapshot = await _firestore
          .collection('productos')
          .where('vendedorId', isEqualTo: widget.vendedorId)
          .orderBy('fecha', descending: true)
          .limit(20)
          .get();

      if (mounted) {
        setState(() {
          _productos = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      }
    } catch (e) {
      // Error al cargar productos
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header con fondo de imagen
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Imagen de fondo
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/interfaz.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Botón de volver
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Foto de perfil
                    Positioned(
                      left: 20,
                      bottom: -40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: _fotoPerfil != null
                              ? NetworkImage(_fotoPerfil!)
                              : null,
                          child: _fotoPerfil == null
                              ? const Icon(
                                  Icons.store,
                                  size: 40,
                                  color: Color(0xFF007BFF),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Información básica
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nombreTienda,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _comunidad,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '$_seguidores seguidores',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Botones de acción
                      Row(
                        children: [
                          // Botón de contactar
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final currentUserId =
                                    FirebaseAuth.instance.currentUser!.uid;
                                if (widget.vendedorId == currentUserId) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No puedes enviarte mensajes a ti mismo',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.orange,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      vendedorId: widget.vendedorId,
                                      vendedorNombre: _nombreTienda,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF28A745),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Contactar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Botón de seguir
                          Expanded(
                            child: _cargandoSeguir
                                ? Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : OutlinedButton(
                                    onPressed: _toggleSeguir,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _estaSiguiendo
                                          ? Colors.grey[100]
                                          : Colors.white,
                                      foregroundColor: _estaSiguiendo
                                          ? Colors.black87
                                          : const Color(0xFF007BFF),
                                      side: BorderSide(
                                        color: _estaSiguiendo
                                            ? Colors.grey[400]!
                                            : const Color(0xFF007BFF),
                                        width: 1.5,
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _estaSiguiendo
                                              ? Icons.check
                                              : Icons.person_add_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _estaSiguiendo
                                              ? 'Siguiendo'
                                              : 'Seguir',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción
                if (_descripcion.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Container(
                      width: double.infinity,
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
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Color(0xFF007BFF),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Descripción',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _descripcion,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Historia (solo si existe)
                if (_historia.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_stories,
                                size: 20,
                                color: Color(0xFF007BFF),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Nuestra Historia',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _historia,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Productos
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Productos',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_productos.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'No hay productos disponibles',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _productos.length,
                          itemBuilder: (context, index) {
                            final producto = _productos[index];
                            final imagenes =
                                producto['imagenes'] as List<dynamic>?;
                            final primeraImagen =
                                imagenes != null && imagenes.isNotEmpty
                                ? imagenes[0] as String
                                : null;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalleProductoScreen(
                                      producto: producto,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Imagen
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: primeraImagen != null
                                          ? Image.network(
                                              primeraImagen,
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    width: 72,
                                                    height: 72,
                                                    color: Colors.grey[100],
                                                    child: Icon(
                                                      Icons.image_outlined,
                                                      color: Colors.grey[400],
                                                      size: 28,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              width: 72,
                                              height: 72,
                                              color: Colors.grey[100],
                                              child: Icon(
                                                Icons.image_outlined,
                                                color: Colors.grey[400],
                                                size: 28,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producto['nombre'] ?? 'Sin nombre',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              producto['categoria'] ??
                                                  'Sin categoría',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '\$${producto['precio'] ?? '0'}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(
                                                      0xFF007BFF,
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' /Kg',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(
                                                      0xFF007BFF,
                                                    ).withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
