import 'package:flutter/material.dart';

class PerfilHeaderBackground extends StatelessWidget {
  const PerfilHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🖼️ Fondo con imagen
        Container(
          height: 180,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icons/interfaz.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 🌫️ Degradado para contraste del texto o íconos
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 🔙 Botón de retroceso
        SafeArea(
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
