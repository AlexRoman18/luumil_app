import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/comer/register_forms.dart';
import 'package:luumil_app/widgets/comer/register_header.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo
          // Fondo temático en lugar de imagen decorativa
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.onSurface.withAlpha((0.45 * 255).round()),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Header (logo + título)
          const RegisterHeader(),

          // Panel blanco (sube un poco menos para no tapar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const RegisterForm(heightFactor: 0.70),
          ),
        ],
      ),
    );
  }
}
