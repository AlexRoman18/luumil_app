import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luumil_app/auth/auth_service.dart';
import 'package:luumil_app/widgets/usuario/custom_text_field.dart';
import '../../screens/usuario/iniciarsesion_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController comunidadController = TextEditingController();
  final AuthService authService = AuthService();

  Future<void> registerUser() async {
    final nombre = nombreController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final comunidad = comunidadController.text.trim();

    // Validaciones mínimas
    if (nombre.isEmpty) {
      _showMessage("Ingrese su nombre");
      return;
    }

    if (email.isEmpty) {
      _showMessage("Ingrese un correo electrónico");
      return;
    }

    if (password.length < 6) {
      _showMessage("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (comunidad.isEmpty) {
      _showMessage("Ingrese su comunidad");
      return;
    }

    try {
      print('INTENTANDO REGISTRO...');
      final result = await authService.registerWithEmailPassword(
        email,
        password,
        nombre,
        comunidad,
      );
      print('USUARIO CREADO: ${result.user?.uid}');

      // Cerrar todas las pantallas y volver a AuthGate
      if (mounted) {
        // Cerrar pantallas hasta llegar a la raíz (AuthGate)
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e, stack) {
      print('🔥 ERROR REGISTRO 🔥');
      print(e);
      print(stack);
      _showMessage("Error inesperado al registrarse");
    }
  }

  void _handleFirebaseError(FirebaseAuthException e) {
    String message = "Error al registrarse";

    switch (e.code) {
      case 'email-already-in-use':
        message = "Este correo ya está registrado";
        break;
      case 'invalid-email':
        message = "El correo no tiene un formato válido";
        break;
      case 'weak-password':
        message = "La contraseña es muy débil";
        break;
    }

    _showMessage(message);
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.70,
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
                CustomTextField(
                  hint: 'Nombre',
                  icon: Icons.person,
                  controller: nombreController,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hint: 'Correo electrónico',
                  icon: Icons.email,
                  controller: emailController,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hint: 'Contraseña',
                  icon: Icons.lock,
                  obscure: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hint: 'Comunidad',
                  icon: Icons.location_on,
                  controller: comunidadController,
                ),
                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidó su contraseña?',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tiene cuenta?'),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text(
                        'Inicie sesión',
                        style: TextStyle(
                          color: Color(0xFF007BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
