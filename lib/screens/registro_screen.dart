import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/register_forms.dart';
import 'package:luumil_app/widgets/register_header.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF007BFF),
      body: SafeArea(
        child: Stack(
          children: [
            RegisterHeader(),
            RegisterForm(),
          ],
        ),
      ),
    );
  }
}
