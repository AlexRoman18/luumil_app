import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:luumil_app/screens/usuario/pago_tarjeta_screen.dart';
import 'package:luumil_app/screens/usuario/pago_paypal_screen.dart';
import 'package:luumil_app/screens/usuario/pago_mercadopago_screen.dart';

class ReferenciasPagoScreen extends StatefulWidget {
  const ReferenciasPagoScreen({super.key});

  @override
  State<ReferenciasPagoScreen> createState() => _ReferenciasPagoScreenState();
}

class _ReferenciasPagoScreenState extends State<ReferenciasPagoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Referencias de Pago',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('referencias_pago')
            .where('usuarioId', isEqualTo: _userId)
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
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes referencias de pago',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final referencias = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: referencias.length,
            itemBuilder: (context, index) {
              final referencia =
                  referencias[index].data() as Map<String, dynamic>;
              final monto = referencia['monto'];
              final concepto = referencia['concepto'] ?? '';
              final estado = referencia['estado'] ?? 'pendiente';
              final vendedorId = referencia['vendedorId'];
              final referenciaId = referencias[index].id;
              final timestamp = referencia['timestamp'] as Timestamp?;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('usuarios').doc(vendedorId).get(),
                builder: (context, vendorSnapshot) {
                  String nombreVendedor = 'Vendedor';
                  String? fotoVendedor;

                  if (vendorSnapshot.hasData && vendorSnapshot.data!.exists) {
                    final vendorData =
                        vendorSnapshot.data!.data() as Map<String, dynamic>;
                    nombreVendedor = vendorData['nombreTienda'] ?? 'Vendedor';
                    fotoVendedor = vendorData['fotoPerfil'];
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: estado == 'pendiente'
                            ? const Color(0xFFFFC107)
                            : const Color(0xFF28A745),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF007BFF),
                                backgroundImage: fotoVendedor != null
                                    ? NetworkImage(fotoVendedor)
                                    : null,
                                child: fotoVendedor == null
                                    ? Text(
                                        nombreVendedor[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombreVendedor,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (timestamp != null)
                                      Text(
                                        _formatearFecha(timestamp.toDate()),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: estado == 'pendiente'
                                      ? const Color(0xFFFFF3CD)
                                      : const Color(0xFFD4EDDA),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  estado == 'pendiente'
                                      ? 'Pendiente'
                                      : 'Pagado',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: estado == 'pendiente'
                                        ? const Color(0xFF856404)
                                        : const Color(0xFF155724),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            concepto,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$$monto MXN',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF007BFF),
                                ),
                              ),
                              if (estado == 'pendiente')
                                ElevatedButton.icon(
                                  onPressed: () => _mostrarOpcionesPago(
                                    context,
                                    referenciaId,
                                    monto,
                                    nombreVendedor,
                                  ),
                                  icon: const Icon(
                                    Icons.payment,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Pagar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF28A745),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
          );
        },
      ),
    );
  }

  void _mostrarOpcionesPago(
    BuildContext context,
    String referenciaId,
    double monto,
    String vendedorNombre,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona método de pago',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paga \$$monto MXN a $vendedorNombre',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildMetodoPagoOption(
              context,
              'PayPal',
              Icons.payments,
              const Color(0xFF0070BA),
              () => _abrirPagoPayPal(context, referenciaId, monto),
            ),
            const SizedBox(height: 12),
            _buildMetodoPagoOption(
              context,
              'Mercado Pago',
              Icons.account_balance_wallet,
              const Color(0xFF009EE3),
              () => _abrirPagoMercadoPago(context, referenciaId, monto),
            ),
            const SizedBox(height: 12),
            _buildMetodoPagoOption(
              context,
              'Tarjeta de Crédito/Débito',
              Icons.credit_card,
              const Color(0xFF6C757D),
              () => _abrirPagoTarjeta(context, referenciaId, monto),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoPagoOption(
    BuildContext context,
    String nombre,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nombre,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirPagoTarjeta(
    BuildContext context,
    String referenciaId,
    double monto,
  ) async {
    Navigator.pop(context); // Cerrar bottom sheet

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PagoTarjetaScreen(monto: monto, referenciaId: referenciaId),
      ),
    );

    if (resultado != null && resultado['exito'] == true) {
      await _confirmarPago(resultado, referenciaId);
    }
  }

  Future<void> _abrirPagoPayPal(
    BuildContext context,
    String referenciaId,
    double monto,
  ) async {
    Navigator.pop(context);

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PagoPaypalScreen(monto: monto, referenciaId: referenciaId),
      ),
    );

    if (resultado != null && resultado['exito'] == true) {
      await _confirmarPago(resultado, referenciaId);
    }
  }

  Future<void> _abrirPagoMercadoPago(
    BuildContext context,
    String referenciaId,
    double monto,
  ) async {
    Navigator.pop(context);

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PagoMercadoPagoScreen(monto: monto, referenciaId: referenciaId),
      ),
    );

    if (resultado != null && resultado['exito'] == true) {
      await _confirmarPago(resultado, referenciaId);
    }
  }

  Future<void> _confirmarPago(
    Map<String, dynamic> resultado,
    String referenciaId,
  ) async {
    // Mostrar diálogo de procesamiento
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Procesando pago...',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Por favor espera...'),
          ],
        ),
      ),
    );

    // Simular verificación
    await Future.delayed(const Duration(seconds: 1));

    // Actualizar estado en Firestore
    await _firestore.collection('referencias_pago').doc(referenciaId).update({
      'estado': 'pagado',
      'metodoPago': resultado['metodoPago'],
      'fechaPago': FieldValue.serverTimestamp(),
      'detallesPago': resultado,
    });

    // Obtener datos del documento para el email
    final doc = await _firestore
        .collection('referencias_pago')
        .doc(referenciaId)
        .get();
    final data = doc.data()!;

    // Obtener nombre del vendedor desde colección usuarios
    String nombreVendedor = 'Vendedor';
    final vendedorId = data['vendedorId'];
    if (vendedorId != null) {
      final vendorDoc = await _firestore
          .collection('usuarios')
          .doc(vendedorId)
          .get();
      if (vendorDoc.exists) {
        final vendorData = vendorDoc.data() as Map<String, dynamic>;
        nombreVendedor = vendorData['nombreTienda'] ?? 'Vendedor';
      }
    }

    await _enviarEmailComprobante(
      referenciaId: referenciaId,
      nombreVendedor: nombreVendedor,
      concepto: data['concepto'] ?? '',
      monto: (data['monto'] ?? 0).toString(),
      metodoPago: resultado['metodoPago'] ?? '',
    );

    if (!mounted) return;
    Navigator.pop(context); // Cerrar diálogo de carga

    // Mostrar confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF28A745), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Pago exitoso!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu pago se ha procesado correctamente.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: Color(0xFF007BFF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Se envió el comprobante a tu correo.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
            ),
            child: Text(
              'Aceptar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarEmailComprobante({
    required String referenciaId,
    required String nombreVendedor,
    required String concepto,
    required String monto,
    required String metodoPago,
  }) async {
    const serviceId = 'service_luumilapp';
    const templateId = 'template_luumilApp';
    const publicKey = 'VXoxooW7X9KT__9oP';

    final user = FirebaseAuth.instance.currentUser;
    final emailUsuario = user?.email ?? '';

    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'email_usuario': emailUsuario,
            'referenciaId': referenciaId,
            'nombreVendedor': nombreVendedor,
            'concepto': concepto,
            'monto': monto,
            'metodoPago': metodoPago,
            'fecha': fecha,
          },
        }),
      );
      debugPrint('EmailJS status: ${response.statusCode}');
      debugPrint('EmailJS body: ${response.body}');
      debugPrint('Email destino: $emailUsuario');
    } catch (e) {
      debugPrint('EmailJS error: $e');
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');
      return 'Hoy a las $hora:$minuto';
    } else if (diferencia.inDays == 1) {
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');
      return 'Ayer a las $hora:$minuto';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
