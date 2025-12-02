import 'package:flutter/material.dart';
import 'package:luumil_app/screens/comer/perfil_screen.dart';
import 'package:luumil_app/screens/comer/subir_producto_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Ir a la pantalla de "Subir productos"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NuevoProductoPage()),
      );
    } else if (index == 0) {
      // Aquí puedes agregar navegación a la pantalla principal
      // Ejemplo: Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      // Aquí puedes agregar navegación al perfilJ
      // Ejemplo: Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Principal',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'Subir productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}
