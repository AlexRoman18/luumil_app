import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PagoTarjetaScreen extends StatefulWidget {
  final double monto;
  final String referenciaId;

  const PagoTarjetaScreen({
    super.key,
    required this.monto,
    required this.referenciaId,
  });

  @override
  State<PagoTarjetaScreen> createState() => _PagoTarjetaScreenState();
}

class _PagoTarjetaScreenState extends State<PagoTarjetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroTarjetaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _vencimientoController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _procesando = false;

  @override
  void dispose() {
    _numeroTarjetaController.dispose();
    _nombreController.dispose();
    _vencimientoController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _formatearNumeroTarjeta(String text) {
    text = text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  String _formatearVencimiento(String text) {
    text = text.replaceAll('/', '');
    if (text.length >= 2) {
      return '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return text;
  }

  String? _validarNumeroTarjeta(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa el número de tarjeta';
    }
    final numero = value.replaceAll(' ', '');
    if (numero.length != 16) {
      return 'El número debe tener 16 dígitos';
    }
    return null;
  }

  String? _validarVencimiento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa la fecha de vencimiento';
    }
    if (!value.contains('/') || value.length != 5) {
      return 'Formato: MM/AA';
    }
    final partes = value.split('/');
    final mes = int.tryParse(partes[0]);
    if (mes == null || mes < 1 || mes > 12) {
      return 'Mes inválido';
    }
    return null;
  }

  Future<void> _procesarPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _procesando = true);

    // Simular procesamiento
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _procesando = false);

    // Retornar resultado exitoso
    Navigator.pop(context, {
      'exito': true,
      'metodoPago': 'tarjeta',
      'ultimos4Digitos': _numeroTarjetaController.text
          .replaceAll(' ', '')
          .substring(12),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pago con tarjeta',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta visual
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 32,
                        ),
                        Text(
                          'VISA',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _numeroTarjetaController.text.isEmpty
                          ? '**** **** **** ****'
                          : _formatearNumeroTarjeta(
                              _numeroTarjetaController.text.padRight(16, '*'),
                            ),
                      style: GoogleFonts.robotoMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TITULAR',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _nombreController.text.isEmpty
                                  ? 'NOMBRE COMPLETO'
                                  : _nombreController.text.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'VENCE',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _vencimientoController.text.isEmpty
                                  ? 'MM/AA'
                                  : _vencimientoController.text,
                              style: GoogleFonts.robotoMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Monto a pagar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF007BFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF007BFF).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total a pagar:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${widget.monto.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007BFF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Formulario
              Text(
                'Datos de la tarjeta',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Número de tarjeta
              TextFormField(
                controller: _numeroTarjetaController,
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: _validarNumeroTarjeta,
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Nombre del titular
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del titular',
                  hintText: 'Como aparece en la tarjeta',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el nombre del titular';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Vencimiento y CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vencimientoController,
                      decoration: InputDecoration(
                        labelText: 'Vencimiento',
                        hintText: 'MM/AA',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: _validarVencimiento,
                      onChanged: (value) {
                        setState(() {
                          if (value.length >= 2 && !value.contains('/')) {
                            _vencimientoController.text = _formatearVencimiento(
                              value,
                            );
                            _vencimientoController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _vencimientoController.text.length,
                                  ),
                                );
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'CVV requerido';
                        }
                        if (value.length < 3) {
                          return 'CVV inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botón de pago
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _procesando ? null : _procesarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28A745),
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
                          'Pagar \$${widget.monto.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Mensaje de seguridad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Pago 100% seguro y encriptado',
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
      ),
    );
  }
}
