import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luumil_app/screens/iniciarsesion_screen.dart';
import 'package:luumil_app/screens/pantallainicio_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras Firebase responde
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Usuario logueado
        if (snapshot.hasData) {
          return const PantallaInicio(); // o Tutorial
        }

        // Usuario NO logueado
        return const LoginScreen();
      },
    );
  }
}
