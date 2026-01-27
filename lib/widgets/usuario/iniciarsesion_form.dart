import 'package:flutter/material.dart';
import 'package:luumil_app/screens/usuario/registro_screen.dart';
import 'package:luumil_app/widgets/usuario/custom_text_field.dart';
import 'package:luumil_app/widgets/usuario/buttons.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: AppSpacing.md),

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

                SizedBox(height: AppSpacing.xl),

                // Botón principal
                ModernButton(
                  text: 'Iniciar Sesión',
                  onPressed: _isLoading ? null : _handleLogin,
                  loading: _isLoading,
                  icon: Icons.login,
                ),

                SizedBox(height: AppSpacing.md),

                // Botón Google
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/icons/buscar.png',
                      width: 20,
                      height: 20,
                    ),
                    label: const Text(
                      'Continuar con Google',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.md),

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
                      child: Text(
                        'Registrese',
                        style: TextStyle(
                          color: AppColors.primary,
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
