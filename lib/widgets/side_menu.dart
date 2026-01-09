import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luumil_app/screens/comer/registro_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int navDrawerIndex = 0;

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
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('¿Quieres convertirte en comerciante?'),
                  content: const Text('Podrás registrar tus productos'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // Cierra el diálogo
                      },
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // Cierra el diálogo

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
        const NavigationDrawerDestination(
          icon: Icon(Icons.local_offer_outlined),
          label: Text('Vender'),
        ),
      ],
    );
  }
}
