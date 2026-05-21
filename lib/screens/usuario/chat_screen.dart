import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:luumil_app/services/cache_service.dart';
import 'package:luumil_app/services/cloudinary_service.dart';
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
  StreamSubscription<QuerySnapshot>? _leidoSubscription;

  @override
  void initState() {
    super.initState();
    _marcarMensajesComoLeidos();
    _escucharMensajesEntrantes();
  }

  Future<void> _marcarMensajesComoLeidos() async {
    final chatId = _getChatId();

    final mensajesNoLeidos = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensajes')
        .where('leido', isEqualTo: false)
        .where('senderId', isNotEqualTo: _userId)
        .get();

    if (mensajesNoLeidos.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in mensajesNoLeidos.docs) {
      batch.update(doc.reference, {'leido': true});
    }
    await batch.commit();
  }

  void _escucharMensajesEntrantes() {
    final chatId = _getChatId();

    _leidoSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensajes')
        .where('leido', isEqualTo: false)
        .where('senderId', isNotEqualTo: _userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) return;
          final batch = _firestore.batch();
          for (var doc in snapshot.docs) {
            batch.update(doc.reference, {'leido': true});
          }
          batch.commit();
        });
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
          'senderRole': widget.esVendedor ? 'vendedor' : 'usuario',
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
    final costoEnvio = seleccionProductos['costoEnvio'] as double? ?? 0.0;

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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Productos:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${(total - costoEnvio).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (costoEnvio > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Envío:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${costoEnvio.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
            'costoEnvio': costoEnvio,
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
            'costoEnvio': costoEnvio,
            'concepto': concepto.isEmpty ? 'Pedido' : concepto,
            'productos': productos,
            'cantidadProductos': productos.length,
            'senderId': _userId,
            'senderRole': widget.esVendedor ? 'vendedor' : 'usuario',
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
    _leidoSubscription?.cancel();
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

                // Si es vendedor, marcar mensajes como leídos en tiempo real
                if (widget.esVendedor) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _marcarMensajesComoLeidos();
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final mensaje =
                        mensajes[index].data() as Map<String, dynamic>;
                    final docId = mensajes[index].id;
                    // Verificar que el senderId coincida Y que el rol del sender coincida con el rol actual
                    final senderRole = mensaje['senderRole'] ?? 'usuario';
                    final rolActual = widget.esVendedor
                        ? 'vendedor'
                        : 'usuario';
                    final esMio =
                        mensaje['senderId'] == _userId &&
                        senderRole == rolActual;
                    final timestamp = mensaje['timestamp'] as Timestamp?;
                    final tipo = mensaje['tipo'] ?? 'texto';

                    return GestureDetector(
                      onLongPress: esMio && tipo == 'texto'
                          ? () => _mostrarOpcionesMensaje(
                              docId,
                              mensaje['texto'] ?? '',
                            )
                          : null,
                      child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: esMio
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: esMio
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (tipo == 'comprobante_pago')
                                _buildComprobantePagoWidget(mensaje, esMio)
                              else
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
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
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: tipo == 'referencia_pago'
                                      ? _buildReferenciaPagoWidget(
                                          mensaje,
                                          esMio,
                                        )
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
                                                _formatearHora(
                                                  timestamp.toDate(),
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: esMio
                                                      ? Colors.white70
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                            if (mensaje['editado'] == true) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'Editado',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontStyle: FontStyle.italic,
                                                  color: esMio
                                                      ? Colors.white54
                                                      : Colors.grey[400],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                ),
                              if (tipo == 'referencia_pago' &&
                                  !esMio &&
                                  !widget.esVendedor)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: InkWell(
                                    onTap: () => _enviarFotoComprobante(
                                      mensaje['referenciaId'] as String? ?? '',
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF007BFF,
                                        ).withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF007BFF,
                                          ).withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.attach_file,
                                            size: 14,
                                            color: Color(0xFF007BFF),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Adjuntar comprobante',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF007BFF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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

  Future<void> _enviarFotoComprobante(String referenciaId) async {
    if (referenciaId.isEmpty) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF007BFF)),
      ),
    );

    try {
      final url = await CloudinaryService.subirImagen(File(picked.path));
      final chatId = _getChatId();

      await _firestore.collection('referencias_pago').doc(referenciaId).update({
        'comprobanteUrl': url,
      });

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('mensajes')
          .add({
            'tipo': 'comprobante_pago',
            'imageUrl': url,
            'referenciaId': referenciaId,
            'senderId': _userId,
            'senderRole': 'usuario',
            'timestamp': FieldValue.serverTimestamp(),
            'leido': false,
          });

      await _firestore.collection('chats').doc(chatId).set({
        'ultimoMensaje': '📷 Comprobante de pago',
        'ultimoTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comprobante enviado ✓'),
          backgroundColor: Color(0xFF28A745),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar el comprobante'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarOpcionesMensaje(String docId, String textoActual) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFF007BFF)),
              title: Text(
                'Editar mensaje',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _editarMensaje(docId, textoActual);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Eliminar mensaje',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _eliminarMensaje(docId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editarMensaje(String docId, String textoActual) async {
    final controller = TextEditingController(text: textoActual);

    final nuevoTexto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Editar mensaje',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Guardar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (nuevoTexto == null || nuevoTexto.isEmpty || nuevoTexto == textoActual) {
      return;
    }

    final chatId = _getChatId();
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensajes')
        .doc(docId)
        .update({'texto': nuevoTexto, 'editado': true});

    await _actualizarUltimoMensaje(chatId);
  }

  Future<void> _eliminarMensaje(String docId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Eliminar mensaje?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final chatId = _getChatId();
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensajes')
        .doc(docId)
        .delete();

    await _actualizarUltimoMensaje(chatId);
  }

  Future<void> _actualizarUltimoMensaje(String chatId) async {
    final ultimoQuery = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensajes')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    String ultimoTexto = '';
    Timestamp? ultimoTimestamp;

    if (ultimoQuery.docs.isNotEmpty) {
      final datos = ultimoQuery.docs.first.data();
      final tipo = datos['tipo'] ?? 'texto';
      if (tipo == 'referencia_pago') {
        ultimoTexto = '💰 Referencia de pago';
      } else if (tipo == 'comprobante_pago') {
        ultimoTexto = '📷 Comprobante de pago';
      } else {
        ultimoTexto = datos['texto'] ?? '';
      }
      ultimoTimestamp = datos['timestamp'] as Timestamp?;
    }

    final Map<String, dynamic> update = {'ultimoMensaje': ultimoTexto};
    if (ultimoTimestamp != null) update['ultimoTimestamp'] = ultimoTimestamp;

    await _firestore.collection('chats').doc(chatId).update(update);
  }

  Widget _buildReferenciaPagoWidget(Map<String, dynamic> mensaje, bool esMio) {
    final monto = mensaje['monto'];
    final costoEnvio = mensaje['costoEnvio'] ?? 0.0;
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
          if (costoEnvio > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: esMio ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                Text(
                  '\$${(monto - costoEnvio).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: esMio ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 13,
                      color: esMio ? Colors.white70 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Envío:',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: esMio ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${costoEnvio.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: esMio ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              color: esMio
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
              height: 1,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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

  Widget _buildComprobantePagoWidget(Map<String, dynamic> mensaje, bool esMio) {
    final imageUrl = mensaje['imageUrl'] as String? ?? '';
    final timestamp = mensaje['timestamp'] as Timestamp?;
    return Column(
      crossAxisAlignment: esMio
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 220,
            fit: BoxFit.cover,
            cacheManager: CacheService.cacheManager,
            placeholder: (ctx, url) => Container(
              width: 220,
              height: 150,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 220,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        if (timestamp != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatearHora(timestamp.toDate()),
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ],
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
