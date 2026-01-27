import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Valores por defecto mientras carga
        String rolActual = 'usuario';
        bool puedeSerVendedor = false;
        bool cargando = !snapshot.hasData;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          rolActual = data['rol'] ?? 'usuario';
          puedeSerVendedor = data['puedeSerVendedor'] ?? false;
        }

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
                if (rolActual == 'vendedor') {
                  await _vendorService.cambiarRol('usuario');

                  if (context.mounted) {
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
                else if (puedeSerVendedor && rolActual != 'vendedor') {
                  await _vendorService.cambiarRol('vendedor');

                  if (context.mounted) {
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
                        title: const Text(
                          '¿Quieres convertirte en comerciante?',
                        ),
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
              icon: cargando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      rolActual == 'vendedor'
                          ? Icons.person_outline
                          : puedeSerVendedor
                          ? Icons.store_outlined
                          : Icons.edit_document,
                    ),
              label: Text(
                rolActual == 'vendedor'
                    ? 'Cambiar a Usuario'
                    : puedeSerVendedor
                    ? 'Cambiar a Vendedor'
                    : 'Solicitar ser Vendedor',
              ),
            ),
          ],
        );
      },
    );
  }
}
