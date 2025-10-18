import 'package:flutter/material.dart';
import 'package:luumil_app/screens/iniciarsesion_screen.dart';
import 'package:luumil_app/screens/registro_screen.dart';
import 'package:luumil_app/widgets/buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
          Positioned.fill(
            child: Image.asset('assets/icons/interfaz.png', fit: BoxFit.cover),
          ),
          // Contenido encima del fondo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/logo.png', width: 120),
                const SizedBox(height: 20),
                const Text(
                  'LuumilApp',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300, // controla el ancho visible
                  child: Buttons(
                    color: Colors.white,
                    text: 'Iniciar Sesión',
                    colorText: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 300,
                  child: Buttons(
                    color: Colors.white,
                    text: 'Registrarse',
                    colorText: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
