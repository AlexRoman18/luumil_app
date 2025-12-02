import 'package:flutter/material.dart';

class PerfilHeaderBackground extends StatelessWidget {
  const PerfilHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Fondo temático (reemplaza imagen decorativa)
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 🌫️ Degradado para contraste del texto o íconos
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.onSurface.withAlpha((0.25 * 255).round()),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 🔙 Botón de retroceso
        SafeArea(
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
