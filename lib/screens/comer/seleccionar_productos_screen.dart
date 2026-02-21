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
  final Map<String, double> _precios = {};
  final ValueNotifier<int> _cantidadTotalNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> _totalNotifier = ValueNotifier<double>(0.0);
  final TextEditingController _costoEnvioController = TextEditingController(
    text: '0',
  );
  final ValueNotifier<double> _costoEnvioNotifier = ValueNotifier<double>(0.0);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _actualizarCantidad(String productoId, int cantidad, double precio) {
    _cantidades[productoId] = cantidad;
    _precios[productoId] = precio;
    _cantidadTotalNotifier.value = _cantidades.values.fold<int>(
      0,
      (a, b) => a + b,
    );

    // Calcular nuevo total
    double nuevoTotal = 0;
    _cantidades.forEach((id, cant) {
      if (cant > 0) {
        nuevoTotal += (_precios[id] ?? 0) * cant;
      }
    });
    _totalNotifier.value = nuevoTotal;
  }

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
  void initState() {
    super.initState();
    _costoEnvioController.addListener(() {
      final valor = double.tryParse(_costoEnvioController.text) ?? 0.0;
      _costoEnvioNotifier.value = valor;
    });
  }

  @override
  void dispose() {
    _costoEnvioController.dispose();
    _costoEnvioNotifier.dispose();
    _cantidadTotalNotifier.dispose();
    _totalNotifier.dispose();
    super.dispose();
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

          // Inicializar precios si es necesario
          for (var doc in productos) {
            if (!_precios.containsKey(doc.id)) {
              final data = doc.data() as Map<String, dynamic>;
              _precios[doc.id] = _parsePrecio(data['precio']);
            }
          }

          return Column(
            children: [
              // Lista de productos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final doc = productos[index];
                    final productoId = doc.id;
                    final cantidadInicial = _cantidades[productoId] ?? 0;

                    return _ProductoItem(
                      key: ValueKey(productoId),
                      doc: doc,
                      cantidadInicial: cantidadInicial,
                      onCantidadChanged: _actualizarCantidad,
                      parsePrecio: _parsePrecio,
                      obtenerImagen: _obtenerPrimeraImagen,
                    );
                  },
                ),
              ),

              // Barra inferior con total y botón
              ValueListenableBuilder<int>(
                valueListenable: _cantidadTotalNotifier,
                builder: (context, cantidadTotal, child) {
                  return Container(
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
                          // Campo de costo de envío
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Costo de envío:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _costoEnvioController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                      hintText: '0.00',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[400],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF007BFF),
                                          width: 1.5,
                                        ),
                                      ),
                                      prefixText: '\$ ',
                                      prefixStyle: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Resumen
                          ValueListenableBuilder<double>(
                            valueListenable: _totalNotifier,
                            builder: (context, total, _) {
                              return ValueListenableBuilder<double>(
                                valueListenable: _costoEnvioNotifier,
                                builder: (context, costoEnvio, child) {
                                  return Container(
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
                                            : [
                                                Colors.grey[100]!,
                                                Colors.grey[50]!,
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Subtotal:',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '\$${total.toStringAsFixed(2)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (costoEnvio > 0) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .local_shipping_outlined,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Envío:',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '\$${costoEnvio.toStringAsFixed(2)}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Total a cobrar',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: cantidadTotal > 0
                                                        ? const Color(
                                                            0xFF007BFF,
                                                          )
                                                        : Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.shopping_bag,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '$cantidadTotal',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '\$${(total + costoEnvio).toStringAsFixed(2)}',
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
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
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
                                          _obtenerProductosSeleccionados(
                                            productos,
                                          );
                                      Navigator.pop(context, {
                                        'productos': seleccionados,
                                        'total':
                                            _totalNotifier.value +
                                            _costoEnvioNotifier.value,
                                        'costoEnvio': _costoEnvioNotifier.value,
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
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// Widget separado para cada item de producto
class _ProductoItem extends StatefulWidget {
  final DocumentSnapshot doc;
  final int cantidadInicial;
  final Function(String productoId, int cantidad, double precio)
  onCantidadChanged;
  final double Function(dynamic) parsePrecio;
  final String Function(Map<String, dynamic>) obtenerImagen;

  const _ProductoItem({
    super.key,
    required this.doc,
    required this.cantidadInicial,
    required this.onCantidadChanged,
    required this.parsePrecio,
    required this.obtenerImagen,
  });

  @override
  State<_ProductoItem> createState() => _ProductoItemState();
}

class _ProductoItemState extends State<_ProductoItem> {
  late int _cantidad;
  late double _precio;

  @override
  void initState() {
    super.initState();
    _cantidad = widget.cantidadInicial;
    final data = widget.doc.data() as Map<String, dynamic>;
    _precio = widget.parsePrecio(data['precio']);
  }

  void _incrementar() {
    setState(() {
      _cantidad++;
    });
    widget.onCantidadChanged(widget.doc.id, _cantidad, _precio);
  }

  void _decrementar() {
    if (_cantidad > 0) {
      setState(() {
        _cantidad--;
      });
      widget.onCantidadChanged(widget.doc.id, _cantidad, _precio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final nombre = data['nombre'] ?? 'Sin nombre';
    final imagenUrl = widget.obtenerImagen(data);

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
                  : Icon(Icons.fastfood, color: Colors.grey[400], size: 32),
            ),
            const SizedBox(width: 12),

            // Información del producto
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
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${_precio.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF28A745),
                          ),
                        ),
                        TextSpan(
                          text: ' /Kg',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
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

            // Controles de cantidad
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Botón menos
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _cantidad > 0 ? _decrementar : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.remove,
                          size: 20,
                          color: _cantidad > 0
                              ? const Color(0xFF007BFF)
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),

                  // Cantidad
                  Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    alignment: Alignment.center,
                    child: Text(
                      _cantidad.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _cantidad > 0
                            ? const Color(0xFF007BFF)
                            : Colors.grey[600],
                      ),
                    ),
                  ),

                  // Botón más
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _incrementar,
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
  }
}
