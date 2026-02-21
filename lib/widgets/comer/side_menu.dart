import 'package:flutter/material.dart';
import 'package:luumil_app/services/vendor_service.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';
import 'package:luumil_app/screens/usuario/pantallainicio_screen.dart';
import 'package:luumil_app/screens/comer/mensajes_vendedor_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return NavigationDrawer(
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (int index) {
        setState(() {
          navDrawerIndex = index;
        });

        switch (index) {
          case 0:
            // Principal (Dashboard)
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
            break;
          case 1:
            // Mensajes
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MensajesVendedorScreen()),
            );
            break;
          case 2:
            // Cambiar a Usuario
            _cambiarAUsuario();
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
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text('Principal', style: GoogleFonts.poppins()),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: Text('Mensajes', style: GoogleFonts.poppins()),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: Text('Cambiar a Usuario', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }

  Future<void> _cambiarAUsuario() async {
    await _vendorService.cambiarRol('usuario');
    if (mounted) {
      Navigator.pop(context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PantallaInicio()),
      );
    }
  }
}
