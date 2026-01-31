import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luumil_app/screens/comer/registro_screen.dart';
import 'package:luumil_app/services/vendor_service.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';
import 'package:luumil_app/screens/usuario/pantallainicio_screen.dart';
import 'package:luumil_app/screens/usuario/perfil_screen.dart';
import 'package:luumil_app/screens/usuario/mi_actividad_screen.dart';

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

        // Construir destinos dinámicamente para mantener índices coherentes
        final List<NavigationDrawerDestination> destinations = [];
        final List<Function()> actions = [];

        destinations.add(
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_outlined),
            label: Text('Principal'),
          ),
        );
        actions.add(() {
          Navigator.pop(context);
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PantallaInicio()));
        });

        if (rolActual == 'usuario') {
          destinations.add(
            const NavigationDrawerDestination(
              icon: Icon(Icons.person_outline),
              label: Text('Perfil'),
            ),
          );
          actions.add(() {
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          });

          destinations.add(
            const NavigationDrawerDestination(
              icon: Icon(Icons.favorite_outline),
              label: Text('Mi Actividad'),
            ),
          );
          actions.add(() {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MiActividadScreen()),
            );
          });
        }

        // Acción para cambiar/solicitar rol
        destinations.add(
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
        );

        actions.add(() async {
          // Manejo asíncrono dentro de la acción
          if (rolActual == 'vendedor') {
            await _vendorService.cambiarRol('usuario');
            if (context.mounted) {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PantallaInicio()));
            }
          } else if (puedeSerVendedor && rolActual != 'vendedor') {
            await _vendorService.cambiarRol('vendedor');
            if (context.mounted) {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            }
          } else {
            // Mostrar diálogo para solicitar ser vendedor
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('¿Quieres convertirte en comerciante?'),
                  content: const Text('Podrás registrar tus productos'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
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
        });

        return NavigationDrawer(
          selectedIndex: navDrawerIndex,
          onDestinationSelected: (int index) {
            setState(() {
              navDrawerIndex = index;
            });

            // Ejecutar acción asociada
            if (index >= 0 && index < actions.length) {
              final action = actions[index];
              action();
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
            ...destinations,
          ],
        );
      },
    );
  }
}
