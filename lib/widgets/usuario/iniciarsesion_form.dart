import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luumil_app/screens/usuario/registro_screen.dart';
import 'package:luumil_app/widgets/usuario/custom_text_field.dart';
import 'package:luumil_app/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validar campos
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese correo y contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Iniciar sesión con Firebase
      await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Cerrar todas las pantallas y volver a AuthGate
      if (mounted) {
        // Cerrar pantallas hasta llegar a la raíz (AuthGate)
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error al iniciar sesión';

      switch (e.code) {
        case 'user-not-found':
          message = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          message = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          message = 'Correo electrónico inválido';
          break;
        case 'user-disabled':
          message = 'Usuario deshabilitado';
          break;
        case 'too-many-requests':
          message = 'Demasiados intentos. Intente más tarde';
          break;
        default:
          message = 'Error: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

                CustomTextField(
                  hint: 'Correo electrónico',
                  icon: Icons.email,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: 'Contraseña',
                  icon: Icons.lock,
                  obscure: true,
                  controller: _passwordController,
                ),

                const SizedBox(height: 2),

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

                const SizedBox(height: 30),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
                    const Text(
                      '¿No tiene cuenta?',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text(
                        'Registrese',
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
