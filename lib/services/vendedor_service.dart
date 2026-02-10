import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendedorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Seguir/dejar de seguir a un vendedor
  Future<void> toggleSeguir(String vendedorId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('usuarios').doc(userId);
    final vendedorRef = _firestore.collection('usuarios').doc(vendedorId);

    final userDoc = await userRef.get();
    final userData = userDoc.data() ?? {};
    final List<dynamic> siguiendo = userData['siguiendo'] ?? [];

    if (siguiendo.contains(vendedorId)) {
      // Dejar de seguir
      await userRef.update({
        'siguiendo': FieldValue.arrayRemove([vendedorId]),
      });
      await vendedorRef.update({'seguidores': FieldValue.increment(-1)});
    } else {
      // Seguir
      await userRef.update({
        'siguiendo': FieldValue.arrayUnion([vendedorId]),
      });
      await vendedorRef.update({'seguidores': FieldValue.increment(1)});
    }
  }

  // Verificar si el usuario sigue a un vendedor
  Future<bool> estaSiguiendo(String vendedorId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final userDoc = await _firestore.collection('usuarios').doc(userId).get();
    final userData = userDoc.data() ?? {};
    final List<dynamic> siguiendo = userData['siguiendo'] ?? [];

    return siguiendo.contains(vendedorId);
  }

  // Obtener estadísticas del vendedor actual
  Future<Map<String, dynamic>> obtenerEstadisticasVendedor() async {
    final vendedorId = _auth.currentUser?.uid;
    if (vendedorId == null) {
      return {
        'totalLikes': 0,
        'promedioEstrellas': 0.0,
        'seguidores': 0,
        'totalResenas': 0,
      };
    }

    // Obtener datos del vendedor
    final vendedorDoc = await _firestore
        .collection('usuarios')
        .doc(vendedorId)
        .get();
    final vendedorData = vendedorDoc.data() ?? {};

    // Obtener productos del vendedor
    final productosSnapshot = await _firestore
        .collection('productos')
        .where('vendedorId', isEqualTo: vendedorId)
        .get();

    int totalLikes = 0;
    double sumaEstrellas = 0;
    int totalResenas = 0;

    for (var doc in productosSnapshot.docs) {
      final data = doc.data();
      totalLikes += (data['totalLikes'] ?? 0) as int;
      final promedio = (data['promedioEstrellas'] ?? 0.0).toDouble();
      final numResenas = (data['totalResenas'] ?? 0) as int;

      if (numResenas > 0) {
        sumaEstrellas += promedio * numResenas;
        totalResenas += numResenas;
      }
    }

    final promedioEstrellas = totalResenas > 0
        ? sumaEstrellas / totalResenas
        : 0.0;

    return {
      'totalLikes': totalLikes,
      'promedioEstrellas': promedioEstrellas,
      'seguidores': vendedorData['seguidores'] ?? 0,
      'totalResenas': totalResenas,
    };
  }

  // Obtener actividad reciente (likes y seguidores)
  Stream<List<Map<String, dynamic>>> obtenerActividadReciente() {
    final vendedorId = _auth.currentUser?.uid;
    if (vendedorId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('productos')
        .where('vendedorId', isEqualTo: vendedorId)
        .snapshots()
        .asyncMap((productosSnapshot) async {
          List<Map<String, dynamic>> actividades = [];

          // Lista de IDs de productos del vendedor
          List<String> productosIds = productosSnapshot.docs
              .map((doc) => doc.id)
              .toList();
          Map<String, String> productosNombres = {};

          for (var doc in productosSnapshot.docs) {
            productosNombres[doc.id] = doc.data()['nombre'] ?? 'Producto';
          }

          // Obtener likes desde la colección 'likes'
          if (productosIds.isNotEmpty) {
            for (var productoId in productosIds) {
              final likesSnapshot = await _firestore
                  .collection('likes')
                  .where('productoId', isEqualTo: productoId)
                  .orderBy('fecha', descending: true)
                  .limit(10)
                  .get();

              for (var likeDoc in likesSnapshot.docs) {
                final likeData = likeDoc.data();
                final userId = likeData['userId'];
                final fecha = likeData['fecha'] as Timestamp?;

                // Obtener datos del usuario
                final userDoc = await _firestore
                    .collection('usuarios')
                    .doc(userId)
                    .get();

                if (userDoc.exists) {
                  final userData = userDoc.data() ?? {};

                  actividades.add({
                    'tipo': 'like',
                    'userId': userId,
                    'userName':
                        userData['nombrePersonal'] ??
                        userData['nombre'] ??
                        'Usuario',
                    'userFoto': userData['fotoPerfil'] ?? '',
                    'productoId': productoId,
                    'productoNombre': productosNombres[productoId],
                    'fecha': fecha,
                  });
                }
              }
            }
          }

          // Obtener reseñas recientes de los productos
          for (var productoDoc in productosSnapshot.docs) {
            final productoId = productoDoc.id;
            final productoNombre = productoDoc.data()['nombre'] ?? 'Producto';

            final resenasSnapshot = await _firestore
                .collection('resenas')
                .where('productoId', isEqualTo: productoId)
                .orderBy('fecha', descending: true)
                .limit(5)
                .get();

            for (var resenaDoc in resenasSnapshot.docs) {
              final resenaData = resenaDoc.data();
              final userId = resenaData['userId'];

              // Obtener datos del usuario
              final userDoc = await _firestore
                  .collection('usuarios')
                  .doc(userId)
                  .get();
              final userData = userDoc.data() ?? {};

              final estrellas = resenaData['estrellas'] ?? 0;
              final comentario = resenaData['comentario'] ?? '';
              final fecha = resenaData['fecha'] as Timestamp?;

              actividades.add({
                'tipo': 'resena',
                'userId': userId,
                'userName':
                    userData['nombrePersonal'] ??
                    userData['nombre'] ??
                    'Usuario',
                'userFoto': userData['fotoPerfil'] ?? '',
                'productoId': productoId,
                'productoNombre': productoNombre,
                'estrellas': estrellas,
                'comentario': comentario,
                'fecha': fecha,
              });
            }
          }

          // Obtener seguidores recientes
          final usuariosSnapshot = await _firestore
              .collection('usuarios')
              .where('siguiendo', arrayContains: vendedorId)
              .limit(10)
              .get();

          for (var userDoc in usuariosSnapshot.docs) {
            final userData = userDoc.data();
            actividades.add({
              'tipo': 'seguidor',
              'userId': userDoc.id,
              'userName':
                  userData['nombrePersonal'] ?? userData['nombre'] ?? 'Usuario',
              'userFoto': userData['fotoPerfil'] ?? '',
              'fecha': userData['fechaRegistro'] as Timestamp?,
            });
          }

          // Ordenar por fecha
          actividades.sort((a, b) {
            final fechaA = a['fecha'] as Timestamp?;
            final fechaB = b['fecha'] as Timestamp?;
            if (fechaA == null || fechaB == null) return 0;
            return fechaB.compareTo(fechaA);
          });

          return actividades.take(10).toList();
        });
  }

  // Obtener usuarios que le dieron like a productos del vendedor
  Future<List<Map<String, dynamic>>> obtenerUsuariosConLikes() async {
    final vendedorId = _auth.currentUser?.uid;
    if (vendedorId == null) return [];

    // Obtener productos del vendedor
    final productosSnapshot = await _firestore
        .collection('productos')
        .where('vendedorId', isEqualTo: vendedorId)
        .get();

    Set<String> usuariosIds = {};
    Map<String, String> productosPorUsuario = {};

    // Obtener todas las reseñas de esos productos
    for (var productoDoc in productosSnapshot.docs) {
      final productoId = productoDoc.id;
      final productoNombre = productoDoc.data()['nombre'] ?? 'Producto';

      final resenasSnapshot = await _firestore
          .collection('resenas')
          .where('productoId', isEqualTo: productoId)
          .get();

      for (var resenaDoc in resenasSnapshot.docs) {
        final userId = resenaDoc.data()['userId'];
        usuariosIds.add(userId);
        productosPorUsuario[userId] = productoNombre;
      }
    }

    // Obtener datos de los usuarios
    List<Map<String, dynamic>> usuarios = [];
    for (var userId in usuariosIds) {
      final userDoc = await _firestore.collection('usuarios').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        usuarios.add({
          'userId': userId,
          'nombre': userData['nombre'] ?? 'Usuario',
          'fotoPerfil': userData['fotoPerfil'] ?? '',
          'productoNombre': productosPorUsuario[userId],
        });
      }
    }

    return usuarios;
  }
}
