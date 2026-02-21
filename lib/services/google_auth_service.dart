import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para forzar selección de cuenta (útil para registro)
  Future<Map<String, String>?> getGoogleUserData() async {
    try {
      // Cerrar sesión primero para forzar selección de cuenta
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null;
      }

      // Retornar datos del usuario sin hacer login en Firebase aún
      return {
        'nombre': googleUser.displayName ?? '',
        'email': googleUser.email,
        'foto': googleUser.photoUrl ?? '',
      };
    } catch (e) {
      throw Exception('Error al obtener datos de Google: $e');
    }
  }

  // Login: Solo permite usuarios ya registrados
  Future<UserCredential?> signInWithGoogle({
    bool forceAccountSelection = false,
  }) async {
    try {
      // Si se requiere forzar selección de cuenta, cerrar sesión primero
      if (forceAccountSelection) {
        await _googleSignIn.signOut();
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // VERIFICAR si el usuario existe en Firestore
      final userDoc = await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Usuario no registrado - cerrar sesión y lanzar error
        await signOut();
        throw Exception(
          'Esta cuenta no está registrada. Por favor regístrate primero.',
        );
      }

      // Usuario existe - actualizar datos
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .update({
            'email': userCredential.user!.email ?? '',
            'nombre':
                userCredential.user!.displayName ??
                userDoc.data()?['nombre'] ??
                'Usuario',
            'fotoPerfil':
                userCredential.user!.photoURL ??
                userDoc.data()?['fotoPerfil'] ??
                '',
          });

      return userCredential;
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  // Registro: Crea nuevos usuarios o permite login si ya existe
  Future<UserCredential?> registerWithGoogle({
    bool forceAccountSelection = false,
  }) async {
    try {
      // Si se requiere forzar selección de cuenta, cerrar sesión primero
      if (forceAccountSelection) {
        await _googleSignIn.signOut();
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // VERIFICAR si el usuario YA está registrado en Firestore
      final userDoc = await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // Usuario ya registrado - cerrar sesión y lanzar error
        await signOut();
        throw 'Esta cuenta ya está registrada. Por favor inicia sesión en lugar de registrarte.';
      }

      // Usuario nuevo - crear documento en Firestore
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
            'email': userCredential.user!.email ?? '',
            'nombre': userCredential.user!.displayName ?? 'Usuario',
            'nombrePersonal': userCredential.user!.displayName ?? 'Usuario',
            'fotoPerfil': userCredential.user!.photoURL ?? '',
            'rol': 'usuario',
            'productosLikeados': [],
            'siguiendo': [],
            'seguidores': 0,
            'comunidad': '',
            'fechaRegistro': FieldValue.serverTimestamp(),
          });

      return userCredential;
    } catch (e) {
      if (e is String) {
        // Es nuestro mensaje personalizado
        rethrow;
      }
      throw 'Error al registrar con Google: $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
