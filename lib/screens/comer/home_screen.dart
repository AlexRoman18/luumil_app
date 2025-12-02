import 'package:flutter/material.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';
import 'package:luumil_app/screens/comer/registro_screen.dart';
import 'package:luumil_app/widgets/comer/buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo basado en el tema (reemplaza imagen decorativa)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            color: theme.colorScheme.onSurface.withAlpha((0.12 * 255).round()),
          ), // Sutil capa para contraste
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
                  Text(
                    'LuumilApp',
                    style: theme.textTheme.titleLarge?.copyWith(
                      letterSpacing: 1.2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Botón Iniciar Sesión
                  Buttons(
                    text: 'Iniciar Sesión',
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
                    text: 'Registrarse',
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
