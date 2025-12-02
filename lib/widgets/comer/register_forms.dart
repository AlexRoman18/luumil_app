import 'package:flutter/material.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';
import 'package:luumil_app/widgets/comer/custom_text_field.dart';
import 'package:luumil_app/widgets/comer/cameraButton.dart';

class RegisterForm extends StatelessWidget {
  final double heightFactor;

  const RegisterForm({super.key, this.heightFactor = 0.7});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: size.height * heightFactor,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withAlpha(
                (0.12 * 255).round(),
              ),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // 🔹 Nombre del negocio
                const CustomTextField(
                  hint: 'Nombre del negocio',
                  icon: Icons.store,
                ),
                const SizedBox(height: 14),

                // 🔹 Descripción corta
                const CustomTextField(
                  hint: 'Descripción corta',
                  icon: Icons.description,
                ),

                const SizedBox(height: 18),

                // 🔹 Texto para imágenes
                Text(
                  'Por favor, adjunte mínimo 3 imágenes que evidencien la existencia de sus ventas',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.75 * 255).round(),
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // 🔹 Botón de cámara
                const CameraButton(),
                const SizedBox(height: 20),

                // 🔹 Botón principal (Enviar)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      'Enviar solicitud',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
