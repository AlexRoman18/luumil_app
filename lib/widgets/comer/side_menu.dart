import 'package:flutter/material.dart';
import 'package:luumil_app/screens/comer/mensajes_vendedor_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
      onDestinationSelected: (int index) {
        setState(() {
          navDrawerIndex = index;
        });

        switch (index) {
          case 0:
            // Mensajes
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MensajesVendedorScreen()),
            );
            break;
          case 1:
            // Subir producto (ya existe)
            break;
          case 2:
            // Mis productos
            break;
          case 3:
            // Estadísticas
            break;
        }
      },
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(28, hasNotch ? 0 : 20, 16, 10),
          child: Text(
            'Menú Vendedor',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: Text('Mensajes', style: GoogleFonts.poppins()),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.add_a_photo_outlined),
          selectedIcon: const Icon(Icons.add_a_photo),
          label: Text('Subir Producto', style: GoogleFonts.poppins()),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.inventory_outlined),
          selectedIcon: const Icon(Icons.inventory),
          label: Text('Mis Productos', style: GoogleFonts.poppins()),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: Text('Estadísticas', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
