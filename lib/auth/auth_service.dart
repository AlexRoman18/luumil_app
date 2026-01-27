import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Servicio optimizado para autenticación con Firebase
class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Registra un nuevo usuario con email y contraseña
  Future<UserCredential> registerWithEmailPassword(
    String email,
    String password,
    String nombre,
    String comunidad, {
    LatLng? ubicacion,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar datos adicionales en Firestore
      final userData = {
        'nombrePersonal': nombre,
        'email': email,
        'comunidad': comunidad,
        'rol': 'usuario',
        'puedeSerVendedor': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
      };

      // Agregar ubicación si existe
      if (ubicacion != null) {
        userData['ubicacion'] = {
          'latitude': ubicacion.latitude,
          'longitude': ubicacion.longitude,
        };
      }

      await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .set(userData);

      return credential;
    } on FirebaseAuthException catch (e) {
      // Relanzar con mensaje más claro
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Inicia sesión con email y contraseña
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Usuario actual
  User? get currentUser => _auth.currentUser;

  /// Stream de cambios en autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Maneja excepciones de Firebase Auth y retorna mensajes en español
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('La contraseña es demasiado débil');
      case 'email-already-in-use':
        return Exception('Este correo ya está registrado');
      case 'invalid-email':
        return Exception('Correo electrónico inválido');
      case 'user-not-found':
        return Exception('Usuario no encontrado');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'user-disabled':
        return Exception('Este usuario ha sido deshabilitado');
      case 'too-many-requests':
        return Exception('Demasiados intentos. Intenta más tarde');
      default:
        return Exception('Error de autenticación: ${e.message}');
    }
  }
}
