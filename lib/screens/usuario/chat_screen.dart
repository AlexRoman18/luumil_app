import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luumil_app/screens/comer/seleccionar_productos_screen.dart';

class ChatScreen extends StatefulWidget {
  final String vendedorId;
  final String vendedorNombre;
  final bool esVendedor;

  const ChatScreen({
    super.key,
    required this.vendedorId,
    required this.vendedorNombre,
    this.esVendedor = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  double _parsePrecio(dynamic precio) {
    if (precio == null) return 0.0;
    if (precio is double) return precio;
    if (precio is int) return precio.toDouble();
    if (precio is String) {
      return double.tryParse(precio.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  String _getChatId() {
    // Crear ID único para el chat (siempre en el mismo orden)
    final ids = [_userId, widget.vendedorId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _enviarMensaje() async {
    final mensaje = _mensajeController.text.trim();
    if (mensaje.isEmpty) return;

    final chatId = _getChatId();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensajes')
        .add({
          'texto': mensaje,
          'senderId': _userId,
          'timestamp': FieldValue.serverTimestamp(),
          'leido': false,
          'tipo': 'texto',
        });

    // Actualizar último mensaje del chat
    await _firestore.collection('chats').doc(chatId).set({
      'participantes': [_userId, widget.vendedorId],
      'ultimoMensaje': mensaje,
      'ultimoTimestamp': FieldValue.serverTimestamp(),
      'vendedorId': widget.esVendedor ? _userId : widget.vendedorId,
      'usuarioId': widget.esVendedor ? widget.vendedorId : _userId,
    }, SetOptions(merge: true));

    _mensajeController.clear();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _enviarReferenciaPago() async {
    if (!widget.esVendedor) return;

    // Primero seleccionar productos
    final seleccionProductos = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const SeleccionarProductosScreen(),
      ),
    );

    if (seleccionProductos == null) return;

    final productos =
        seleccionProductos['productos'] as List<Map<String, dynamic>>;
    final total = seleccionProductos['total'] as double;

    // Luego pedir concepto adicional (opcional)
    final TextEditingController conceptoController = TextEditingController();

    if (!mounted) return;

    final concepto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF007BFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Color(0xFF007BFF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Detalles de Pago',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF28A745).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF28A745),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Concepto (opcional)',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: conceptoController,
              decoration: InputDecoration(
                hintText: 'Ej: Pago de pedido, Anticipo, etc.',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF007BFF),
                    width: 2,
                  ),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, conceptoController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Enviar Referencia',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (concepto != null) {
      final chatId = _getChatId();

      // Crear referencia de pago en Firestore
      final referenciaDoc = await _firestore
          .collection('referencias_pago')
          .add({
            'vendedorId': _userId,
            'usuarioId': widget.vendedorId,
            'chatId': chatId,
            'monto': total,
            'concepto': concepto.isEmpty ? 'Pedido' : concepto,
            'productos': productos,
            'estado': 'pendiente',
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Enviar mensaje con la referencia
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('mensajes')
          .add({
            'tipo': 'referencia_pago',
            'referenciaId': referenciaDoc.id,
            'monto': total,
            'concepto': concepto.isEmpty ? 'Pedido' : concepto,
            'productos': productos,
            'cantidadProductos': productos.length,
            'senderId': _userId,
            'timestamp': FieldValue.serverTimestamp(),
            'leido': false,
          });

      // Actualizar último mensaje
      await _firestore.collection('chats').doc(chatId).set({
        'participantes': [_userId, widget.vendedorId],
        'ultimoMensaje':
            '🛒 Referencia: \$${total.toStringAsFixed(2)} (${productos.length} productos)',
        'ultimoTimestamp': FieldValue.serverTimestamp(),
        'vendedorId': _userId,
        'usuarioId': widget.vendedorId,
      }, SetOptions(merge: true));
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vendedorNombre,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_getChatId())
                  .collection('mensajes')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay mensajes aún',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Envía un mensaje para comenzar',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final mensajes = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final mensaje =
                        mensajes[index].data() as Map<String, dynamic>;
                    final esMio = mensaje['senderId'] == _userId;
                    final timestamp = mensaje['timestamp'] as Timestamp?;
                    final tipo = mensaje['tipo'] ?? 'texto';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: esMio
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: tipo == 'referencia_pago'
                                  ? (esMio
                                        ? const Color(0xFF28A745)
                                        : const Color(0xFFE8F5E9))
                                  : (esMio
                                        ? const Color(0xFF007BFF)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: tipo == 'referencia_pago'
                                ? _buildReferenciaPagoWidget(mensaje, esMio)
                                : Column(
                                    crossAxisAlignment: esMio
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mensaje['texto'] ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: esMio
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (timestamp != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatearHora(timestamp.toDate()),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: esMio
                                                ? Colors.white70
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input de mensaje
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (widget.esVendedor) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.attach_money,
                      color: Color(0xFF28A745),
                    ),
                    onPressed: _enviarReferenciaPago,
                    tooltip: 'Enviar referencia de pago',
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _mensajeController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF007BFF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _enviarMensaje,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenciaPagoWidget(Map<String, dynamic> mensaje, bool esMio) {
    final monto = mensaje['monto'];
    final concepto = mensaje['concepto'] ?? 'Pedido';
    final timestamp = mensaje['timestamp'] as Timestamp?;
    final productos = mensaje['productos'] as List<dynamic>? ?? [];

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: esMio
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF28A745).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: esMio ? Colors.white : const Color(0xFF28A745),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Referencia de Pago',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: esMio ? Colors.white : const Color(0xFF28A745),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: esMio ? Colors.white70 : Colors.grey[700],
                ),
              ),
              Text(
                '\$${monto.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: esMio ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),

          // Concepto
          if (concepto.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: esMio
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.label_outline,
                    size: 14,
                    color: esMio ? Colors.white70 : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      concepto,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: esMio ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Lista de productos
          if (productos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esMio
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: esMio
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 16,
                        color: esMio ? Colors.white70 : const Color(0xFF007BFF),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${productos.length} producto${productos.length != 1 ? 's' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: esMio ? Colors.white : const Color(0xFF007BFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...productos.take(3).map((producto) {
                    final nombre = producto['nombre'] ?? 'Producto';
                    final precio = _parsePrecio(producto['precio']);
                    final cantidad = producto['cantidad'] ?? 1;
                    final subtotal = precio * cantidad;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: esMio
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$nombre x$cantidad',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: esMio ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: esMio ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (productos.length > 3) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+ ${productos.length - 3} más',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: esMio ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Timestamp
          if (timestamp != null) ...[
            const SizedBox(height: 10),
            Text(
              _formatearHora(timestamp.toDate()),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: esMio ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatearHora(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');
      return '$hora:$minuto';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
