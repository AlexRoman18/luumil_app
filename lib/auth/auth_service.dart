import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar nuevo usuario
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
    String nombre,
    String comunidad,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Guardar datos adicionales en Firestore
    await _firestore.collection('usuarios').doc(credential.user!.uid).set({
      'nombre': nombre,
      'email': email,
      'comunidad': comunidad,
      'rol': 'usuario',
      'puedeSerVendedor': false,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Iniciar sesión
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Cerrar sesión
  Future<void> signOut() {
    return _auth.signOut();
  }
}
