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

      // Crear o actualizar documento del usuario en Firestore
      await _crearOActualizarUsuario(userCredential.user);

      return userCredential;
    } catch (e) {
      throw Exception('Error al registrar con Google: $e');
    }
  }

  Future<void> _crearOActualizarUsuario(User? user) async {
    if (user == null) return;

    final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();

    if (!userDoc.exists) {
      // Crear nuevo usuario
      await _firestore.collection('usuarios').doc(user.uid).set({
        'email': user.email ?? '',
        'nombre': user.displayName ?? 'Usuario',
        'fotoPerfil': user.photoURL ?? '',
        'rol': 'usuario', // Por defecto es usuario normal
        'productosLikeados': [],
        'siguiendo': [],
        'seguidores': 0,
        'comunidad': '',
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
    } else {
      // Actualizar datos existentes
      await _firestore.collection('usuarios').doc(user.uid).update({
        'email': user.email ?? '',
        'nombre': user.displayName ?? userDoc.data()?['nombre'] ?? 'Usuario',
        'fotoPerfil': user.photoURL ?? userDoc.data()?['fotoPerfil'] ?? '',
      });
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
