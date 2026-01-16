import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/usuario/register_forms.dart';
import 'package:luumil_app/widgets/usuario/register_header.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo con imagen
            Positioned.fill(
              child: Image.asset(
                'assets/icons/interfaz.png',
                fit: BoxFit.cover,
              ),
            ),
            // Contenido encima del fondo
            const RegisterHeader(),
            const RegisterForm(),
          ],
        ),
      ),
    );
  }
}
