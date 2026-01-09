import 'package:flutter/material.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';
import 'package:luumil_app/screens/comer/registro_screen.dart';
import 'package:luumil_app/widgets/comer/buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con degradado o imagen
          Image.asset('assets/icons/interfaz.png', fit: BoxFit.cover),
          Container(
            color: Colors.black.withOpacity(0.2), // Sutil capa para contraste
          ),
          // Contenido principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/icons/logo.png',
                    width: size.width * 0.35,
                  ),
                  const SizedBox(height: 20),

                  // Nombre de la app
                  const Text(
                    'LuumilApp',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Botón Iniciar Sesión
                  Buttons(
                    color: Colors.white,
                    text: 'Iniciar Sesión',
                    colorText: Colors.black,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón Registrarse
                  Buttons(
                    color: Colors.white,
                    text: 'Registrarse',
                    colorText: Colors.black,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
