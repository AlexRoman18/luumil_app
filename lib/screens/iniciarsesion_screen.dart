import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/iniciarsesion_form.dart';
import 'package:luumil_app/widgets/login_header.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            const LoginHeader(),
            const LoginForm(),
          ],
        ),
      ),
    );
  }
}
