import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../comer/detalle_producto_screen.dart';
import 'package:luumil_app/widgets/usuario/pasos_modal.dart';

class ProductosComunidadScreen extends StatefulWidget {
  final String comunidad;
  final String? categoria;
  final String? terminoBusqueda;

  const ProductosComunidadScreen({
    super.key,
    required this.comunidad,
    this.categoria,
    this.terminoBusqueda,
  });

  @override
  State<ProductosComunidadScreen> createState() =>
      _ProductosComunidadScreenState();
}

class _ProductosComunidadScreenState extends State<ProductosComunidadScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _productos = [];
  Map<String, Map<String, dynamic>> _vendedores = {};
  bool _cargando = true;

  // ─── Utilidades de búsqueda robusta ───────────────────────────────────────

  String _norm(String s) {
    const acentos = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    var r = s.toLowerCase().trim();
    acentos.forEach((k, v) => r = r.replaceAll(k, v));
    r = r.replaceAll(RegExp(r'[-_]+'), ' ');
    r = r.replaceAll(RegExp(r'\s+'), ' ');
    return r;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final dp = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );
    for (var i = 0; i <= a.length; i++) dp[i][0] = i;
    for (var j = 0; j <= b.length; j++) dp[0][j] = j;
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        dp[i][j] = a[i - 1] == b[j - 1]
            ? dp[i - 1][j - 1]
            : 1 +
                  [
                    dp[i - 1][j],
                    dp[i][j - 1],
                    dp[i - 1][j - 1],
                  ].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[a.length][b.length];
  }

  bool _coincide(String busqueda, String texto) {
    final b = _norm(busqueda);
    final t = _norm(texto);
    if (t.isEmpty || b.isEmpty) return false;
    if (t.contains(b) || b.contains(t)) return true;
    final palabrasB = b.split(' ').where((p) => p.length > 2).toList();
    final palabrasT = t.split(' ').where((p) => p.length > 2).toList();
    if (palabrasB.isNotEmpty && palabrasB.every((p) => t.contains(p)))
      return true;
    for (final pb in palabrasB) {
      final match = palabrasT.any((pt) {
        final maxDist = pb.length <= 4 ? 1 : 2;
        return _levenshtein(pb, pt) <= maxDist;
      });
      if (match) return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      // Si hay término de búsqueda, buscar directamente en productos
      if (widget.terminoBusqueda != null) {
        await _cargarProductosPorBusqueda();
        return;
      }

      final esGlobal =
          widget.comunidad.toLowerCase() == 'todas las comunidades';

      // Obtener todos los usuarios
      final usuariosSnapshot = await _firestore.collection('usuarios').get();

      // Filtrar vendedores
      final vendedoresData = <String, Map<String, dynamic>>{};
      final vendedorIds = usuariosSnapshot.docs
          .where((doc) {
            final data = doc.data();
            final puedeSerVendedor = data['puedeSerVendedor'] ?? false;

            if (!puedeSerVendedor) return false;

            // Si es búsqueda global, incluir todos los vendedores
            if (esGlobal) return true;

            // Si es búsqueda por comunidad, filtrar con matching robusto
            final comunidadUsuario = data['comunidad'] as String? ?? '';
            return _coincide(widget.comunidad, comunidadUsuario);
          })
          .map((doc) {
            vendedoresData[doc.id] = doc.data();
            return doc.id;
          })
          .toList();

      if (vendedorIds.isEmpty) {
        setState(() => _cargando = false);
        return;
      }

      // Cargar productos de esos vendedores
      // Firestore whereIn tiene límite de 10, dividir en chunks si es necesario
      final productos = <Map<String, dynamic>>[];

      for (int i = 0; i < vendedorIds.length; i += 10) {
        final chunk = vendedorIds.skip(i).take(10).toList();

        // Query base
        Query query = _firestore
            .collection('productos')
            .where('vendedorId', whereIn: chunk);

        // Filtrar por categoría si está seleccionada
        if (widget.categoria != null) {
          query = query.where('categoria', isEqualTo: widget.categoria);
        }

        final productosSnapshot = await query
            .orderBy('fecha', descending: true)
            .get();

        productos.addAll(
          productosSnapshot.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList(),
        );
      }

      if (mounted) {
        setState(() {
          _productos = productos;
          _vendedores = vendedoresData;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _cargarProductosPorBusqueda() async {
    try {
      final busqueda = widget.terminoBusqueda!;

      // Obtener todos los productos
      final productosSnapshot = await _firestore.collection('productos').get();

      // Filtrar con matching robusto: nombre, categoría, descripción, tags
      final productosFiltrados = productosSnapshot.docs.where((doc) {
        final data = doc.data();
        final nombre = (data['nombre'] as String?) ?? '';
        final categoria = (data['categoria'] as String?) ?? '';
        final descripcion = (data['descripcion'] as String?) ?? '';
        final tags = ((data['tags'] as List?)?.cast<String>() ?? []).join(' ');
        return _coincide(busqueda, nombre) ||
            _coincide(busqueda, categoria) ||
            _coincide(busqueda, descripcion) ||
            _coincide(busqueda, tags);
      }).toList();

      // Obtener información de vendedores
      final vendedorIds = productosFiltrados
          .map((doc) => doc.data()['vendedorId'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();

      final vendedoresData = <String, Map<String, dynamic>>{};
      if (vendedorIds.isNotEmpty) {
        final usuariosSnapshot = await _firestore.collection('usuarios').get();
        for (var doc in usuariosSnapshot.docs) {
          if (vendedorIds.contains(doc.id)) {
            vendedoresData[doc.id] = doc.data();
          }
        }
      }

      final productos = productosFiltrados
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      if (mounted) {
        setState(() {
          _productos = productos;
          _vendedores = vendedoresData;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.terminoBusqueda != null
                  ? 'Búsqueda: "${widget.terminoBusqueda}"'
                  : widget.comunidad,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (widget.categoria != null)
              Text(
                widget.categoria!,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _productos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos disponibles',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'en ${widget.comunidad}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _productos.length,
              itemBuilder: (context, index) {
                final producto = _productos[index];
                final vendedorId = producto['vendedorId'] as String?;
                final vendedor = vendedorId != null
                    ? _vendedores[vendedorId]
                    : null;
                final nombreTienda = vendedor?['nombreTienda'] ?? 'Tienda';
                final comunidadVendedor = vendedor?['comunidad'] as String?;
                final esBusquedaGeneral = widget.terminoBusqueda != null;
                final imagenes = producto['imagenes'] as List<dynamic>?;
                final primeraImagen = imagenes != null && imagenes.isNotEmpty
                    ? imagenes[0] as String
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 0,
                    child: InkWell(
                      onTap: () {
                        // Agregar información del vendedor al producto
                        final productoCompleto = {
                          ...producto,
                          'nombreTienda': nombreTienda,
                          'comunidadVendedor':
                              comunidadVendedor ?? widget.comunidad,
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
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Imagen del producto
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: primeraImagen != null
                                      ? Image.network(
                                          primeraImagen,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey[100],
                                                  child: Icon(
                                                    Icons.image_outlined,
                                                    color: Colors.grey[400],
                                                    size: 30,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey[100],
                                          child: Icon(
                                            Icons.image_outlined,
                                            color: Colors.grey[400],
                                            size: 30,
                                          ),
                                        ),
                                ),
                                // Ícono de pasos (solo si tiene pasos)
                                if (producto['pasos'] != null &&
                                    (producto['pasos'] as List).isNotEmpty)
                                  Positioned(
                                    top: 2,
                                    left: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => PasosModal(
                                            pasos:
                                                producto['pasos']
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
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
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

                            // Información del producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre de la tienda
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.store_outlined,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          nombreTienda,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Nombre del producto
                                  Text(
                                    producto['nombre'] ?? 'Sin nombre',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // Comunidad (solo en búsqueda general)
                                  if (esBusquedaGeneral &&
                                      comunidadVendedor != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 13,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              comunidadVendedor,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Badge de categoría y precio
                                  Row(
                                    children: [
                                      // Badge de categoría
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue[200]!,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          producto['categoria'] ??
                                              'Sin categoría',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Precio
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '\$${producto['precio'] ?? '0'}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF007BFF),
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' /Kg',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(
                                                  0xFF007BFF,
                                                ).withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Flecha indicadora
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
