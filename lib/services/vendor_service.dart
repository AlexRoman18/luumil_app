import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio optimizado para manejo de funcionalidades de vendedor
class VendorService {
  // Singleton
  static final VendorService _instance = VendorService._internal();
  factory VendorService() => _instance;
  VendorService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Caché simple para reducir lecturas de Firestore
  String? _cachedRol;
  bool? _cachedPuedeSerVendedor;
  Map<String, dynamic>? _cachedPerfil;
  DateTime? _lastCacheUpdate;

  static const _cacheValidityDuration = Duration(minutes: 5);

  /// Verifica si el caché es válido
  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) <
        _cacheValidityDuration;
  }

  /// Limpia el caché
  void clearCache() {
    _cachedRol = null;
    _cachedPuedeSerVendedor = null;
    _cachedPerfil = null;
    _lastCacheUpdate = null;
  }

  /// Obtiene el ID del usuario actual
  String? get currentUserId => _auth.currentUser?.uid;

  /// Obtiene el rol actual del usuario (con caché)
  Future<String> getRolUsuario() async {
    try {
      if (_isCacheValid && _cachedRol != null) {
        return _cachedRol!;
      }

      final userId = currentUserId;
      if (userId == null) return 'usuario';

      final doc = await _firestore.collection('usuarios').doc(userId).get();
      if (!doc.exists) return 'usuario';

      _cachedRol = doc.data()?['rol'] ?? 'usuario';
      _lastCacheUpdate = DateTime.now();

      return _cachedRol!;
    } catch (e) {
      return 'usuario';
    }
  }

  /// Cambia el rol del usuario (vendedor <-> usuario)
  Future<bool> cambiarRol(String nuevoRol) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      await _firestore.collection('usuarios').doc(userId).update({
        'rol': nuevoRol,
        'ultimoCambioRol': FieldValue.serverTimestamp(),
      });

      clearCache(); // Limpiar caché después de actualizar
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si el usuario puede ser vendedor
  Future<bool> puedeSerVendedor() async {
    try {
      if (_isCacheValid && _cachedPuedeSerVendedor != null) {
        return _cachedPuedeSerVendedor!;
      }

      final userId = currentUserId;
      if (userId == null) return false;

      final userDoc = await _firestore.collection('usuarios').doc(userId).get();
      if (!userDoc.exists) return false;

      _cachedPuedeSerVendedor = userDoc.data()?['puedeSerVendedor'] ?? false;
      _lastCacheUpdate = DateTime.now();

      return _cachedPuedeSerVendedor!;
    } catch (e) {
      return false;
    }
  }

  /// Stream de notificaciones no leídas del usuario
  Stream<QuerySnapshot> getNotificaciones() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('notificaciones')
        .where('userId', isEqualTo: userId)
        .where('leida', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .limit(20) // Limitar a 20 para mejor rendimiento
        .snapshots();
  }

  /// Marca una notificación como leída
  Future<bool> marcarNotificacionLeida(String notificacionId) async {
    try {
      await _firestore.collection('notificaciones').doc(notificacionId).update({
        'leida': true,
        'fechaLeida': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stream de productos del vendedor
  Stream<QuerySnapshot> getMisProductos() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('productos')
        .where('vendedorId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .limit(50) // Limitar para mejor rendimiento
        .snapshots();
  }

  /// Obtiene datos del perfil del vendedor (con caché)
  Future<Map<String, dynamic>?> getPerfilVendedor() async {
    try {
      if (_isCacheValid && _cachedPerfil != null) {
        return _cachedPerfil;
      }

      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('usuarios').doc(userId).get();
      if (!doc.exists) return null;

      _cachedPerfil = doc.data();
      _lastCacheUpdate = DateTime.now();

      return _cachedPerfil;
    } catch (e) {
      return null;
    }
  }

  /// Actualiza datos del perfil
  Future<bool> actualizarPerfil({
    String? nombreTienda,
    String? descripcion,
    String? comunidad,
    String? fotoPerfil,
    String? historia,
    Map<String, double>? ubicacion,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      final Map<String, dynamic> updates = {};
      if (nombreTienda != null) updates['nombreTienda'] = nombreTienda;
      if (descripcion != null) updates['descripcion'] = descripcion;
      if (comunidad != null) updates['comunidad'] = comunidad;
      if (fotoPerfil != null) updates['fotoPerfil'] = fotoPerfil;
      if (historia != null) updates['historia'] = historia;
      if (ubicacion != null) updates['ubicacion'] = ubicacion;

      if (updates.isEmpty) return false;

      updates['ultimaActualizacion'] = FieldValue.serverTimestamp();

      await _firestore.collection('usuarios').doc(userId).update(updates);
      clearCache(); // Limpiar caché después de actualizar

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un producto
  Future<bool> eliminarProducto(String productoId) async {
    try {
      await _firestore.collection('productos').doc(productoId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
