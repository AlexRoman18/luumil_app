import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luumil_app/screens/comer/registro_screen.dart';
import 'package:luumil_app/services/vendor_service.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';
import 'package:luumil_app/screens/usuario/pantallainicio_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int navDrawerIndex = 0;
  final VendorService _vendorService = VendorService();
  String _rolActual = 'usuario';
  bool _puedeSerVendedor = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    final rol = await _vendorService.getRolUsuario();
    final puede = await _vendorService.puedeSerVendedor();

    if (mounted) {
      setState(() {
        _rolActual = rol;
        _puedeSerVendedor = puede;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;

    return NavigationDrawer(
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (int index) async {
        if (index != 2) {
          setState(() {
            navDrawerIndex = index;
          });
        }

        switch (index) {
          case 0:
            context.push('');
            break;

          case 1:
            context.push('');
            break;

          case 2:
            // Si ya es vendedor, cambiar a usuario
            if (_rolActual == 'vendedor') {
              setState(() => _cargando = true);
              await _vendorService.cambiarRol('usuario');

              if (mounted) {
                setState(() {
                  _rolActual = 'usuario';
                  _cargando = false;
                });

                Navigator.pop(context); // Cerrar drawer

                // Navegar a PantallaInicio
                Future.microtask(() {
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PantallaInicio(),
                      ),
                    );
                  }
                });
              }
            }
            // Si puede ser vendedor y es usuario, cambiar a vendedor
            else if (_puedeSerVendedor && _rolActual != 'vendedor') {
              setState(() => _cargando = true);
              await _vendorService.cambiarRol('vendedor');

              if (mounted) {
                setState(() {
                  _rolActual = 'vendedor';
                  _cargando = false;
                });

                Navigator.pop(context);

                // Navegar al Dashboard
                Future.microtask(() {
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  }
                });
              }
            }
            // Si no puede ser vendedor, mostrar diálogo de solicitud
            else {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('¿Quieres convertirte en comerciante?'),
                    content: const Text('Podrás registrar tus productos'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Sí'),
                      ),
                    ],
                  );
                },
              );
            }
            break;
        }
      },
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(28, hasNotch ? 0 : 20, 16, 10),
          child: const Text(
            'Menú',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.announcement_outlined),
          label: Text('Principal'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.search_outlined),
          label: Text('Selección de busqueda'),
        ),
        NavigationDrawerDestination(
          icon: _cargando
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _rolActual == 'vendedor'
                      ? Icons.person_outline
                      : _puedeSerVendedor
                      ? Icons.store_outlined
                      : Icons.edit_document,
                ),
          label: Text(
            _rolActual == 'vendedor'
                ? 'Cambiar a Usuario'
                : _puedeSerVendedor
                ? 'Cambiar a Vendedor'
                : 'Solicitar ser Vendedor',
          ),
        ),
      ],
    );
  }
}
