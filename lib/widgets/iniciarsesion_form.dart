import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/custom_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),

                const CustomTextField(
                    hint: 'Correo electrónico', icon: Icons.email),
                const SizedBox(height: 20),
                const CustomTextField(
                    hint: 'Contraseña', icon: Icons.lock, obscure: true),
            
                
                const SizedBox(height: 2),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidó su contraseña?',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Botón Google
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/icons/buscar.png',
                      width: 22,
                      height: 22,
                    ),
                    label: const Text(
                      'Continuar con Google',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Texto de inicio de sesión
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tiene cuenta?',
                        style: TextStyle(fontSize: 14)),
                    TextButton(
                      onPressed: () {
                        // Aquí navegas al login
                      },
                      child: const Text(
                        'Registrese',
                        style: TextStyle(
                          color: Color(0xFF007BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
