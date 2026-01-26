import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el rol actual del usuario
  Future<String> getRolUsuario() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'usuario';

    final doc = await _firestore.collection('usuarios').doc(userId).get();
    if (!doc.exists) return 'usuario';

    return doc.data()?['rol'] ?? 'usuario';
  }

  // Cambiar el rol del usuario (vendedor <-> usuario)
  // IMPORTANTE: NO cambia puedeSerVendedor, solo el rol
  Future<bool> cambiarRol(String nuevoRol) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      await _firestore.collection('usuarios').doc(userId).update({
        'rol': nuevoRol,
      });

      return true;
    } catch (e) {
      print('Error al cambiar rol: $e');
      return false;
    }
  }

  // Verificar si el usuario puede ser vendedor (solicitud aprobada)
  Future<bool> puedeSerVendedor() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    // Verificar en el documento del usuario
    final userDoc = await _firestore.collection('usuarios').doc(userId).get();

    if (!userDoc.exists) return false;

    final puede = userDoc.data()?['puedeSerVendedor'] ?? false;
    return puede;
  }

  // Stream de notificaciones del usuario
  Stream<QuerySnapshot> getNotificaciones() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('notificaciones')
        .where('userId', isEqualTo: userId)
        .where('leida', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // Marcar notificación como leída
  Future<void> marcarNotificacionLeida(String notificacionId) async {
    await _firestore.collection('notificaciones').doc(notificacionId).update({
      'leida': true,
    });
  }

  // Obtener productos del vendedor
  Stream<QuerySnapshot> getMisProductos() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _firestore
        .collection('productos')
        .where('vendedorId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // Obtener datos del perfil del vendedor
  Future<Map<String, dynamic>?> getPerfilVendedor() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore.collection('usuarios').doc(userId).get();
    if (!doc.exists) return null;

    return doc.data();
  }

  // Actualizar datos del perfil
  Future<bool> actualizarPerfil({
    String? nombreTienda,
    String? descripcion,
    String? comunidad,
    String? fotoPerfil,
    String? historia,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final Map<String, dynamic> updates = {};
      if (nombreTienda != null) updates['nombreTienda'] = nombreTienda;
      if (descripcion != null) updates['descripcion'] = descripcion;
      if (comunidad != null) updates['comunidad'] = comunidad;
      if (fotoPerfil != null) updates['fotoPerfil'] = fotoPerfil;
      if (historia != null) updates['historia'] = historia;

      if (updates.isEmpty) return false;

      await _firestore.collection('usuarios').doc(userId).update(updates);
      return true;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }

  // Eliminar producto
  Future<bool> eliminarProducto(String productoId) async {
    try {
      await _firestore.collection('productos').doc(productoId).delete();
      return true;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }
}
