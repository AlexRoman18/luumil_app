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
    if (index == 1) {
      // Ir a la pantalla de "Subir productos"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NuevoProductoPage()),
      ).then((_) {
        // Resetear a Principal cuando regresa
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else if (index == 0) {
      // Ya estamos en Principal, no hacer nada
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      ).then((_) {
        // Resetear a Principal cuando regresa
        setState(() {
          _selectedIndex = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF2196F3),
      unselectedItemColor: Colors.grey,
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
