import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/buttons.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        _buildTextField('Correo electrónico'),
        _buildTextField('Contraseña', obscure: true),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              '¿Olvidó su contraseña?',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Buttons(
          text: 'Iniciar sesión',
          color: Colors.white,
          colorText: Colors.blue.shade800,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Image.asset('assets/icons/google.png', width: 20),
          label: const Text('Continuar con Google'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 30),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            '¿Aún no tienes cuenta? Registrarse',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
