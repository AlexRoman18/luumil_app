import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PagoPaypalScreen extends StatefulWidget {
  final double monto;
  final String referenciaId;

  const PagoPaypalScreen({
    super.key,
    required this.monto,
    required this.referenciaId,
  });

  @override
  State<PagoPaypalScreen> createState() => _PagoPaypalScreenState();
}

class _PagoPaypalScreenState extends State<PagoPaypalScreen> {
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

    // Simular autenticación PayPal
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _procesando = false);

    // Retornar resultado exitoso
    Navigator.pop(context, {
      'exito': true,
      'metodoPago': 'paypal',
      'email': _emailController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0070BA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/icons/paypal_logo.png',
          height: 24,
          errorBuilder: (_, __, ___) => Text(
            'PayPal',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Logo PayPal
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0070BA).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Color(0xFF0070BA),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Monto
            Center(
              child: Column(
                children: [
                  Text(
                    'Total a pagar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.monto.toStringAsFixed(2)} MXN',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Formulario
            Text(
              'Inicia sesión en PayPal',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico o número de celular',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF0070BA),
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Contraseña
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF0070BA),
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

            // ¿Olvidaste tu contraseña?
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF0070BA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón Iniciar sesión
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _procesando ? null : _procesarPago,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0070BA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
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
                        'Iniciar sesión',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Separador
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 24),

            // Botón crear cuenta
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0070BA), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Crear cuenta',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0070BA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Mensaje de seguridad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Color(0xFF0070BA), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Protección del comprador de PayPal',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
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
