import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagenes = widget.producto['imagenes'] as List? ?? [];
    final nombre = widget.producto['nombre'] ?? 'Sin nombre';
    final precio = widget.producto['precio'] ?? '0';
    final descripcion = widget.producto['descripcion'] ?? 'Sin descripción';
    final categoria = widget.producto['categoria'] ?? 'Sin categoría';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
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
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    'Volver',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
