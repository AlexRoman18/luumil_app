import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeleccionarProductosScreen extends StatefulWidget {
  const SeleccionarProductosScreen({super.key});

  @override
  State<SeleccionarProductosScreen> createState() =>
      _SeleccionarProductosScreenState();
}

class _SeleccionarProductosScreenState
    extends State<SeleccionarProductosScreen> {
  final Map<String, int> _cantidades = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  double _parsePrecio(dynamic precio) {
    if (precio == null) return 0.0;
    if (precio is double) return precio;
    if (precio is int) return precio.toDouble();
    if (precio is String) {
      return double.tryParse(precio.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  String _obtenerPrimeraImagen(Map<String, dynamic> data) {
    // Buscar en diferentes campos posibles
    final imagenes = data['imagenes'] as List<dynamic>?;
    if (imagenes != null && imagenes.isNotEmpty) {
      return imagenes[0].toString();
    }

    final fotos = data['fotos'] as List<dynamic>?;
    if (fotos != null && fotos.isNotEmpty) {
      return fotos[0].toString();
    }

    final fotosProducto = data['fotosProducto'] as List<dynamic>?;
    if (fotosProducto != null && fotosProducto.isNotEmpty) {
      return fotosProducto[0].toString();
    }

    return '';
  }

  double _calcularTotal(List<DocumentSnapshot> productos) {
    double total = 0;
    for (var doc in productos) {
      final data = doc.data() as Map<String, dynamic>;
      final cantidad = _cantidades[doc.id] ?? 0;
      if (cantidad > 0) {
        final precio = _parsePrecio(data['precio']);
        total += precio * cantidad;
      }
    }
    return total;
  }

  List<Map<String, dynamic>> _obtenerProductosSeleccionados(
    List<DocumentSnapshot> productos,
  ) {
    final seleccionados = <Map<String, dynamic>>[];
    for (var doc in productos) {
      final cantidad = _cantidades[doc.id] ?? 0;
      if (cantidad > 0) {
        final data = doc.data() as Map<String, dynamic>;
        seleccionados.add({
          'productoId': doc.id,
          'nombre': data['nombre'] ?? 'Sin nombre',
          'precio': _parsePrecio(data['precio']),
          'cantidad': cantidad,
          'imagenUrl': _obtenerPrimeraImagen(data),
        });
      }
    }
    return seleccionados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Seleccionar Productos',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('productos')
            .where('vendedorId', isEqualTo: _userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar productos',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data?.docs ?? [];

          if (productos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No tienes productos disponibles',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega productos desde tu dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final total = _calcularTotal(productos);
          final cantidadTotal = _cantidades.values.fold<int>(
            0,
            (a, b) => a + b,
          );

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final doc = productos[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final productoId = doc.id;
                    final nombre = data['nombre'] ?? 'Sin nombre';
                    final precio = _parsePrecio(data['precio']);
                    final imagenUrl = _obtenerPrimeraImagen(data);
                    final cantidad = _cantidades[productoId] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Imagen del producto
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[100],
                              ),
                              child: imagenUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imagenUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.fastfood,
                                          color: Colors.grey[400],
                                          size: 32,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.fastfood,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                            ),
                            const SizedBox(width: 14),

                            // Nombre y precio
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF28A745,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '\$${precio.toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF28A745),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Controles de cantidad
                            Container(
                              decoration: BoxDecoration(
                                color: cantidad > 0
                                    ? const Color(
                                        0xFF007BFF,
                                      ).withValues(alpha: 0.08)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Botón menos
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: cantidad > 0
                                          ? () {
                                              setState(() {
                                                _cantidades[productoId] =
                                                    cantidad - 1;
                                              });
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.remove,
                                          size: 20,
                                          color: cantidad > 0
                                              ? const Color(0xFF007BFF)
                                              : Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Cantidad
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      cantidad.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: cantidad > 0
                                            ? const Color(0xFF007BFF)
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),

                                  // Botón más
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _cantidades[productoId] =
                                              cantidad + 1;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const Icon(
                                          Icons.add,
                                          size: 20,
                                          color: Color(0xFF007BFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Barra inferior con total y botón
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Resumen
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: cantidadTotal > 0
                                ? [
                                    const Color(
                                      0xFF007BFF,
                                    ).withValues(alpha: 0.1),
                                    const Color(
                                      0xFF0056b3,
                                    ).withValues(alpha: 0.05),
                                  ]
                                : [Colors.grey[100]!, Colors.grey[50]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total a cobrar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: cantidadTotal > 0
                                        ? const Color(0xFF007BFF)
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: cantidadTotal > 0
                                    ? const Color(0xFF007BFF)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$cantidadTotal',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón enviar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: cantidadTotal > 0
                              ? () {
                                  final seleccionados =
                                      _obtenerProductosSeleccionados(productos);
                                  Navigator.pop(context, {
                                    'productos': seleccionados,
                                    'total': total,
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: cantidadTotal > 0 ? 4 : 0,
                            shadowColor: const Color(
                              0xFF007BFF,
                            ).withValues(alpha: 0.4),
                          ),
                          child: Text(
                            cantidadTotal > 0
                                ? 'Continuar con Referencia'
                                : 'Selecciona productos',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cantidadTotal > 0
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
