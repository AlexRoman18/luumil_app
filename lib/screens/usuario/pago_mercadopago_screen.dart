import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PagoMercadoPagoScreen extends StatefulWidget {
  final double monto;
  final String referenciaId;

  const PagoMercadoPagoScreen({
    super.key,
    required this.monto,
    required this.referenciaId,
  });

  @override
  State<PagoMercadoPagoScreen> createState() => _PagoMercadoPagoScreenState();
}

class _PagoMercadoPagoScreenState extends State<PagoMercadoPagoScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _procesando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _procesarPago() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _procesando = true);

    // Simular autenticación Mercado Pago
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _procesando = false);

    // Retornar resultado exitoso
    Navigator.pop(context, {
      'exito': true,
      'metodoPago': 'mercadopago',
      'email': _emailController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF009EE3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Mercado Pago',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Logo Mercado Pago
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF009EE3), Color(0xFF00B0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF009EE3).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.payment, size: 60, color: Colors.white),
              ),
            ),

            const SizedBox(height: 32),

            // Monto
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF009EE3).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF009EE3).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Monto a pagar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.monto.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF009EE3),
                    ),
                  ),
                  Text(
                    'MXN',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Título
            Text(
              'Ingresa a tu cuenta',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Usa tu cuenta de Mercado Pago',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail o usuario',
                hintText: 'ejemplo@correo.com',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF009EE3),
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // Contraseña
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF009EE3),
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _mostrarPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _mostrarPassword = !_mostrarPassword);
                  },
                ),
              ),
              obscureText: !_mostrarPassword,
            ),

            const SizedBox(height: 12),

            // Recordar usuario
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                  activeColor: const Color(0xFF009EE3),
                ),
                Text(
                  'Recordar usuario',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botón Continuar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _procesando ? null : _procesarPago,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009EE3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _procesando
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Continuar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Olvidé mi contraseña
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Olvidé mi contraseña',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF009EE3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              ],
            ),

            const SizedBox(height: 32),

            // Crear cuenta
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF009EE3), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Crear cuenta de Mercado Pago',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF009EE3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Protección al comprador
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compra Protegida',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Recibe el producto o te devolvemos el dinero',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
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
