import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/services/carrito_service.dart';
import 'package:luumil_app/services/resena_service.dart';
import 'package:luumil_app/screens/comer/resenas_screen.dart';
import 'package:luumil_app/screens/usuario/tienda_perfil_screen.dart';
import 'package:luumil_app/config/gemini/gemini_imp.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;
  final ResenaService _resenaService = ResenaService();
  bool _hasLiked = false;
  bool _isLoadingLike = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _verificarLike();
  }

  Future<void> _verificarLike() async {
    final liked = await _resenaService.hasLiked(widget.producto['id'] ?? '');
    if (mounted) {
      setState(() {
        _hasLiked = liked;
        _isLoadingLike = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _mostrarTradicionBottomSheet() {
    final nombre = widget.producto['nombre'] ?? 'producto';
    final categoria = widget.producto['categoria'] ?? '';
    final descripcion = widget.producto['descripcion'] ?? '';
    final comunidad = widget.producto['comunidadVendedor'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conoce la tradición',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            nombre,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Contenido con streaming
              Expanded(
                child: StreamBuilder<String>(
                  stream: _generarInformacionTradicion(
                    nombre: nombre,
                    categoria: categoria,
                    descripcion: descripcion,
                    comunidad: comunidad,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue[600]!,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Consultando información...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error al generar información',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final contenido = snapshot.data ?? '';

                    if (contenido.isEmpty) {
                      return Center(
                        child: Text(
                          'Esperando información...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue[50]!,
                                  Colors.blue[100]!.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Información generada por IA',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            contenido,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              height: 1.7,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<String> _generarInformacionTradicion({
    required String nombre,
    required String categoria,
    required String descripcion,
    required String comunidad,
  }) async* {
    final gemini = GeminiImp();

    final prompt =
        '''
Eres un experto en tradiciones y cultura mexicana. 

Producto: $nombre
Categoría: $categoria
Descripción: $descripcion
Comunidad: $comunidad

Genera un texto informativo y cultural sobre este producto que incluya:
1. Su origen e historia cultural
2. La tradición detrás de su elaboración
3. Su importancia en la comunidad o región
4. Datos interesantes sobre el producto

Escribe de manera clara, educativa y atractiva en español. El texto debe ser de aproximadamente 200-300 palabras.
''';

    String contenidoCompleto = '';

    try {
      await for (final chunk
          in gemini
              .getResponseStream(prompt)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: (sink) {
                  sink.addError(
                    Exception(
                      'Tiempo de espera agotado. Verifica que tu servidor backend esté corriendo.',
                    ),
                  );
                  sink.close();
                },
              )) {
        contenidoCompleto += chunk;
        yield contenidoCompleto;
      }

      if (contenidoCompleto.isEmpty) {
        throw Exception('No se recibió respuesta del servidor');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagenes = widget.producto['imagenes'] as List? ?? [];
    final nombre = widget.producto['nombre'] ?? 'Sin nombre';
    final precio = widget.producto['precio'] ?? '0';
    final descripcion = widget.producto['descripcion'] ?? 'Sin descripción';
    final categoria = widget.producto['categoria'] ?? 'Sin categoría';
    final nombreTienda = widget.producto['nombreTienda'] ?? 'Tienda';
    final comunidad =
        widget.producto['comunidadVendedor'] ?? 'Ubicación no disponible';
    final totalLikes = widget.producto['totalLikes'] ?? 0;
    final promedioEstrellas = (widget.producto['promedioEstrellas'] ?? 0.0)
        .toDouble();
    final subcategoria = widget.producto['subcategoria'] ?? '';
    final totalResenas = widget.producto['totalResenas'] ?? 0;
    final productoId = widget.producto['id'] ?? '';
    final vendedorId = widget.producto['vendedorId'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Botón de like
              if (!_isLoadingLike)
                IconButton(
                  icon: Icon(
                    _hasLiked ? Icons.favorite : Icons.favorite_border,
                    color: _hasLiked ? Colors.red : Colors.black,
                    size: 28,
                  ),
                  onPressed: () async {
                    await _resenaService.toggleLike(productoId);
                    _verificarLike();
                  },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imagenes.isNotEmpty
                  ? Stack(
                      children: [
                        // Carrusel de imágenes
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: imagenes.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              imagenes[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Indicador de puntos
                        if (imagenes.length > 1)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                imagenes.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Contador de imágenes
                        if (imagenes.length > 1)
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentImageIndex + 1}/${imagenes.length}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$$precio',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF007BFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Estadísticas: Likes y Reseñas
                  Row(
                    children: [
                      // Likes
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$totalLikes',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Estrellas
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ResenasScreen(producto: widget.producto),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                promedioEstrellas > 0
                                    ? promedioEstrellas.toStringAsFixed(1)
                                    : 'Sin calificación',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber[800],
                                ),
                              ),
                              if (totalResenas > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '($totalResenas)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF007BFF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category,
                          size: 16,
                          color: Color(0xFF007BFF),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoria,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF007BFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tienda y ubicación
                  Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nombreTienda,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        comunidad,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Botón para ver perfil de tienda
                  InkWell(
                    onTap: () {
                      if (vendedorId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TiendaPerfilScreen(vendedorId: vendedorId),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF007BFF).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storefront,
                            size: 16,
                            color: Color(0xFF007BFF),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ver perfil de la tienda',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF007BFF),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Color(0xFF007BFF),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Descripción
                  Text(
                    'Descripción',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información adicional
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del producto',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.photo_library,
                          'Fotos',
                          '${imagenes.length} imagen${imagenes.length != 1 ? 'es' : ''}',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.check_circle_outline,
                          'Estado',
                          'Disponible',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Otras tiendas que venden este producto
                  Text(
                    'Otras tiendas que venden este producto',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  StreamBuilder<QuerySnapshot>(
                    stream: subcategoria.isNotEmpty
                        ? FirebaseFirestore.instance
                              .collection('productos')
                              .where('subcategoria', isEqualTo: subcategoria)
                              .where('vendedorId', isNotEqualTo: vendedorId)
                              .limit(10)
                              .snapshots()
                        : FirebaseFirestore.instance
                              .collection('productos')
                              .where('categoria', isEqualTo: categoria)
                              .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red[900],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      // Filtrar productos del mismo vendedor y obtener productos similares
                      final nombreNormalizado = nombre.toLowerCase().trim();
                      final otrosProductos = snapshot.data!.docs
                          .where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final otroVendedorId = data['vendedorId'] ?? '';
                            final otroNombre = (data['nombre'] ?? '')
                                .toString()
                                .toLowerCase()
                                .trim();

                            // Excluir mismo vendedor
                            if (otroVendedorId == vendedorId) return false;

                            // Si tiene subcategoría, ya filtró Firestore
                            if (subcategoria.isNotEmpty) return true;

                            // Si no tiene subcategoría, verificar similitud de nombre
                            // (misma palabra inicial o contenido similar)
                            final palabrasProducto = nombreNormalizado.split(
                              ' ',
                            );
                            final palabrasOtro = otroNombre.split(' ');

                            return palabrasProducto.isNotEmpty &&
                                palabrasOtro.isNotEmpty &&
                                palabrasProducto[0] == palabrasOtro[0];
                          })
                          .take(5)
                          .toList();

                      if (otrosProductos.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: otrosProductos.length,
                        itemBuilder: (context, index) {
                          final doc = otrosProductos[index];
                          final otroProducto =
                              doc.data() as Map<String, dynamic>;
                          final otroVendedorId =
                              otroProducto['vendedorId'] ?? '';

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(otroVendedorId)
                                .get(),
                            builder: (context, vendedorSnapshot) {
                              String otraTienda = 'Tienda';
                              String otraComunidad = 'Ubicación';

                              if (vendedorSnapshot.hasData &&
                                  vendedorSnapshot.data!.exists) {
                                final vendedorData =
                                    vendedorSnapshot.data!.data()
                                        as Map<String, dynamic>;
                                otraTienda =
                                    vendedorData['nombreTienda'] ?? 'Tienda';
                                otraComunidad =
                                    vendedorData['comunidad'] ?? 'Ubicación';
                              }

                              final otrasImagenes =
                                  otroProducto['imagenes'] as List? ?? [];
                              final otroPrecio = otroProducto['precio'] ?? '0';
                              final otroPromedioEstrellas =
                                  (otroProducto['promedioEstrellas'] ?? 0.0)
                                      .toDouble();

                              return GestureDetector(
                                onTap: () {
                                  final productoCompleto = {
                                    'id': doc.id,
                                    ...otroProducto,
                                    'nombreTienda': otraTienda,
                                    'comunidadVendedor': otraComunidad,
                                  };
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetalleProductoScreen(
                                            producto: productoCompleto,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Imagen del producto
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: otrasImagenes.isNotEmpty
                                            ? Image.network(
                                                otrasImagenes[0],
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.image,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Información
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Tienda
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
                                                    otraTienda,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            // Comunidad
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  otraComunidad,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            // Estrellas
                                            if (otroPromedioEstrellas > 0)
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    size: 14,
                                                    color: Colors.amber,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    otroPromedioEstrellas
                                                        .toStringAsFixed(1),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Precio
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$$otroPrecio',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF007BFF),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón Agregar al carrito
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    CarritoService().agregarProducto(widget.producto);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Producto agregado al carrito',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    'Agregar al carrito',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64B5F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Botón Conocer la tradición
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _mostrarTradicionBottomSheet,
                  icon: const Icon(Icons.auto_stories),
                  label: Text(
                    'Conocer la tradición',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF007BFF),
                    side: const BorderSide(
                      color: Color(0xFF007BFF),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
