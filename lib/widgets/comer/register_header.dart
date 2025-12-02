import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 12),
      // 👆 Ajusta la posición vertical
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo responsivo
          Image.asset(
            'assets/icons/logo.png',
            width: width * 0.25,
            height: width * 0.25,
          ),

          const SizedBox(height: 10),

          // Texto centrado y más proporcionado
          Text(
            'Solicitud de registro',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: width * 0.075,
              color: theme.colorScheme.onPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
