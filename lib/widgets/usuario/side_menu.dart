import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luumil_app/screens/comer/registro_screen.dart';
import 'package:luumil_app/services/vendor_service.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';
import 'package:luumil_app/screens/usuario/pantallainicio_screen.dart';
import 'package:luumil_app/screens/usuario/perfil_screen.dart';
import 'package:luumil_app/screens/usuario/mi_actividad_screen.dart';
import 'package:luumil_app/screens/comer/mensajes_vendedor_screen.dart';
import 'package:luumil_app/screens/usuario/mensajes_usuario_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int navDrawerIndex = 0;
  final VendorService _vendorService = VendorService();
  String _lastRole = 'usuario';
  bool _lastPuedeSerVendedor = false;

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

        // Priorizar datos existentes incluso si hay error después
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            final rolValue = data['rol'];
            rolActual = (rolValue is String && rolValue.isNotEmpty)
                ? rolValue
                : 'usuario';
            puedeSerVendedor = data['puedeSerVendedor'] ?? false;
            debugPrint(
              '🔍 SideMenu: Datos cargados - rol=$rolActual (valor original=$rolValue), puedeSerVendedor=$puedeSerVendedor',
            );
          } else {
            debugPrint('⚠️ SideMenu: Documento existe pero data es null');
          }
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            !snapshot.data!.exists) {
          debugPrint(
            '⚠️ SideMenu: Documento del usuario no existe en Firestore para UID: ${user.uid}',
          );
          // Crear documento con valores por defecto
          FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .set({
                'rol': 'usuario',
                'puedeSerVendedor': false,
                'email': user.email ?? '',
                'fechaCreacion': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true))
              .then((_) {
                debugPrint(
                  '✅ SideMenu: Documento creado automáticamente con valores por defecto',
                );
              })
              .catchError((e) {
                debugPrint('❌ SideMenu: Error al crear documento: $e');
              });
        } else if (snapshot.hasError) {
          debugPrint('❌ SideMenu Error: ${snapshot.error}');
        } else {
          debugPrint('⏳ SideMenu: Cargando datos...');
        }

        // Detectar cambios en rol/permisos y resetear índice si es necesario
        if (rolActual != _lastRole ||
            puedeSerVendedor != _lastPuedeSerVendedor) {
          _lastRole = rolActual;
          _lastPuedeSerVendedor = puedeSerVendedor;
          // Resetear a Principal cuando cambia el rol
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                navDrawerIndex = 0;
              });
            }
          });
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

        debugPrint(
          '🔧 SideMenu: Rol actual = "$rolActual" | puedeSerVendedor = $puedeSerVendedor',
        );

        // Tratar 'solicitante' igual que 'usuario'
        bool esUsuario = rolActual == 'usuario' || rolActual == 'solicitante';

        if (esUsuario) {
          debugPrint(
            '✅ SideMenu: Agregando opciones de usuario (Perfil, Mi Actividad, Mensajes)',
          );
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

          destinations.add(
            const NavigationDrawerDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: Text('Mensajes'),
            ),
          );
          actions.add(() {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MensajesUsuarioScreen()),
            );
          });
        } else {
          debugPrint(
            '❌ SideMenu: rol NO es usuario/solicitante, es "$rolActual"',
          );
        }

        // Si es vendedor, agregar opción de Mensajes
        if (rolActual == 'vendedor') {
          debugPrint('✅ SideMenu: Agregando Mensajes de Vendedor');
          destinations.add(
            const NavigationDrawerDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: Text('Mensajes'),
            ),
          );
          actions.add(() {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MensajesVendedorScreen()),
            );
          });
        }

        debugPrint(
          '📊 SideMenu: Total destinos construidos = ${destinations.length}',
        );

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
                        : rolActual == 'solicitante'
                        ? Icons.hourglass_bottom
                        : puedeSerVendedor
                        ? Icons.store_outlined
                        : Icons.edit_document,
                  ),
            label: Text(
              rolActual == 'vendedor'
                  ? 'Cambiar a Usuario'
                  : rolActual == 'solicitante'
                  ? 'Solicitud pendiente'
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
          } else if (rolActual == 'solicitante') {
            // Si ya está solicitando, mostrar mensaje
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Tu solicitud para ser vendedor está en revisión',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
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
          selectedIndex: navDrawerIndex < destinations.length
              ? navDrawerIndex
              : 0,
          onDestinationSelected: (int index) {
            // Validar que el índice sea válido antes de usarlo
            if (index >= 0 && index < actions.length) {
              debugPrint(
                '👆 SideMenu: Tocaste índice $index de ${actions.length} opciones',
              );
              setState(() {
                navDrawerIndex = index;
              });
              // Ejecutar acción asociada
              final action = actions[index];
              action();
            } else {
              debugPrint(
                '❌ SideMenu: Índice inválido: $index (total opciones: ${actions.length})',
              );
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
