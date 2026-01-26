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
    try {
      print('📝 Iniciando registro...');
      print('Email: $email');
      print('Nombre: $nombre');
      print('Comunidad: $comunidad');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Usuario creado en Auth: ${credential.user!.uid}');

      // Guardar datos adicionales en Firestore
      final userData = {
        'nombrePersonal': nombre,
        'email': email,
        'comunidad': comunidad,
        'rol': 'usuario',
        'puedeSerVendedor': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
      };

      print('📤 Guardando en Firestore:');
      print('   - nombrePersonal: $nombre');
      print('   - email: $email');
      print('   - comunidad: $comunidad');

      await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set(userData);

      print('✅ Datos guardados en Firestore correctamente');

      // Verificar que se guardó correctamente
      final doc = await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .get();
      print('🔍 Verificación - Datos recuperados de Firestore:');
      print('   - nombrePersonal: ${doc.data()?['nombrePersonal']}');
      print('   - email: ${doc.data()?['email']}');
      print('   - comunidad: ${doc.data()?['comunidad']}');

      return credential;
    } catch (e, stack) {
      print('❌ ERROR en registerWithEmailPassword:');
      print(e);
      print(stack);
      rethrow;
    }
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
