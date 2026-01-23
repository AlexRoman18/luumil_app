import 'package:flutter/material.dart';
import 'package:luumil_app/services/vendor_service.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';

class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  final VendorService _vendorService = VendorService();
  String _rolActual = 'usuario';
  bool _cargando = true;
  bool _puedeSerVendedor = false;

  @override
  void initState() {
    super.initState();
    _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    final rol = await _vendorService.getRolUsuario();
    final puede = await _vendorService.puedeSerVendedor();

    setState(() {
      _rolActual = rol;
      _puedeSerVendedor = puede;
      _cargando = false;
    });
  }

  Future<void> _cambiarRol() async {
    final nuevoRol = _rolActual == 'vendedor' ? 'usuario' : 'vendedor';

    setState(() => _cargando = true);

    final exito = await _vendorService.cambiarRol(nuevoRol);

    if (exito) {
      setState(() {
        _rolActual = nuevoRol;
        _cargando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nuevoRol == 'vendedor'
                  ? '✅ Modo vendedor activado'
                  : '✅ Modo usuario activado',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Si cambió a vendedor, navegar al Dashboard
        if (nuevoRol == 'vendedor') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } else {
      setState(() => _cargando = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar de rol'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Solo mostrar si puede ser vendedor (solicitud aprobada)
    if (!_puedeSerVendedor && _rolActual != 'vendedor') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _rolActual == 'vendedor'
            ? Colors.green.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _rolActual == 'vendedor' ? Colors.green : Colors.blue,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _rolActual == 'vendedor' ? Icons.store : Icons.person,
            size: 18,
            color: _rolActual == 'vendedor' ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            _rolActual == 'vendedor' ? 'Vendedor' : 'Usuario',
            style: TextStyle(
              color: _rolActual == 'vendedor' ? Colors.green : Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _cambiarRol,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.swap_horiz,
                size: 16,
                color: _rolActual == 'vendedor' ? Colors.green : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
