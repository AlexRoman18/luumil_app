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
    final email = _auth.currentUser?.email;
    print('🔍🔍🔍 getNotificaciones() llamado');
    print('   📧 Email: $email');
    print('   🆔 userId: $userId');

    if (userId == null) {
      print('⚠️⚠️⚠️ Usuario no autenticado, retornando stream vacío');
      return const Stream.empty();
    }

    print('   ✅ Consultando Firestore...');
    print('   📂 Colección: notificaciones');
    print('   🔑 Filtro userId: $userId');
    print('   👁️ Filtro leida: false');

    final stream = _firestore
        .collection('notificaciones')
        .where('userId', isEqualTo: userId)
        .where('leida', isEqualTo: false)
        .orderBy('fecha', descending: true)
        .snapshots();

    // Debug: escuchar el stream para ver qué llega
    stream.listen(
      (snapshot) {
        print('📨📨📨 Stream recibió datos:');
        print('   📊 Total documentos: ${snapshot.docs.length}');
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print(
            '   - ${doc.id}: ${data['titulo']} (userId: ${data['userId']})',
          );
        }
      },
      onError: (error) {
        print('❌❌❌ Error en stream: $error');
      },
    );

    return stream;
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
}
