import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/comer/register_forms.dart';
import 'package:luumil_app/widgets/comer/register_header.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo
          Image.asset('assets/icons/interfaz.png', fit: BoxFit.cover),

          // Degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent],
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
