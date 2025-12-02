import 'package:flutter/material.dart';
import 'package:luumil_app/screens/iniciarsesion_screen.dart';
import 'package:luumil_app/screens/registro_screen.dart';
import 'package:luumil_app/widgets/buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Fondo temático (reemplaza imagen decorativa)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Contenido encima del fondo
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/logo.png', width: 120),
                const SizedBox(height: 20),
                Text(
                  ' LuumilApp',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: 300, // controla el ancho visible
                  child: Buttons(
                    text: 'Iniciar Sesión',
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
                    text: 'Registrarse',
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
