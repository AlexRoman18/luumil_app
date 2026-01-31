import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Resena {
  final String id;
  final String userId;
  final String userName;
  final String productoId;
  final int estrellas; // 1 a 5
  final String? comentario;
  final DateTime fecha;

  Resena({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productoId,
    required this.estrellas,
    this.comentario,
    required this.fecha,
  });

  factory Resena.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Resena(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuario',
      productoId: data['productoId'] ?? '',
      estrellas: data['estrellas'] ?? 0,
      comentario: data['comentario'],
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'productoId': productoId,
      'estrellas': estrellas,
      'comentario': comentario,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}

class ResenaService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Dar o quitar like a un producto
  Future<void> toggleLike(String productoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = _firestore.collection('usuarios').doc(user.uid);
      final userData = await userDoc.get();
      final productosLikeados = List<String>.from(
        userData.data()?['productosLikeados'] ?? [],
      );

      final productoDoc = _firestore.collection('productos').doc(productoId);

      if (productosLikeados.contains(productoId)) {
        // Quitar like
        productosLikeados.remove(productoId);
        await userDoc.update({'productosLikeados': productosLikeados});
        await productoDoc.update({'totalLikes': FieldValue.increment(-1)});

        // Eliminar documento de like
        final likeQuery = await _firestore
            .collection('likes')
            .where('userId', isEqualTo: user.uid)
            .where('productoId', isEqualTo: productoId)
            .limit(1)
            .get();

        for (var doc in likeQuery.docs) {
          await doc.reference.delete();
        }
      } else {
        // Dar like
        productosLikeados.add(productoId);
        await userDoc.update({'productosLikeados': productosLikeados});
        await productoDoc.update({'totalLikes': FieldValue.increment(1)});

        // Crear documento de like con fecha
        await _firestore.collection('likes').add({
          'userId': user.uid,
          'productoId': productoId,
          'fecha': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error al dar/quitar like: $e');
    }
  }

  // Verificar si el usuario dio like a un producto
  Future<bool> hasLiked(String productoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final productosLikeados = List<String>.from(
        userDoc.data()?['productosLikeados'] ?? [],
      );

      return productosLikeados.contains(productoId);
    } catch (e) {
      debugPrint('Error al verificar like: $e');
      return false;
    }
  }

  // Agregar reseña con estrellas
  Future<void> agregarResena({
    required String productoId,
    required int estrellas,
    String? comentario,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Obtener nombre del usuario
      final userDoc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['nombre'] ?? 'Usuario';

      // Verificar si ya tiene una reseña
      final resenaExistente = await _firestore
          .collection('resenas')
          .where('userId', isEqualTo: user.uid)
          .where('productoId', isEqualTo: productoId)
          .get();

      if (resenaExistente.docs.isNotEmpty) {
        // Actualizar reseña existente
        await resenaExistente.docs.first.reference.update({
          'estrellas': estrellas,
          'comentario': comentario,
          'fecha': FieldValue.serverTimestamp(),
        });
      } else {
        // Crear nueva reseña
        await _firestore.collection('resenas').add({
          'userId': user.uid,
          'userName': userName,
          'productoId': productoId,
          'estrellas': estrellas,
          'comentario': comentario,
          'fecha': FieldValue.serverTimestamp(),
        });
      }

      // Recalcular promedio de estrellas del producto
      await _recalcularPromedioEstrellas(productoId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error al agregar reseña: $e');
    }
  }

  // Recalcular promedio de estrellas de un producto
  Future<void> _recalcularPromedioEstrellas(String productoId) async {
    try {
      final resenas = await _firestore
          .collection('resenas')
          .where('productoId', isEqualTo: productoId)
          .get();

      if (resenas.docs.isEmpty) {
        await _firestore.collection('productos').doc(productoId).update({
          'promedioEstrellas': 0.0,
          'totalResenas': 0,
        });
        return;
      }

      double suma = 0;
      for (var doc in resenas.docs) {
        suma += (doc.data()['estrellas'] ?? 0).toDouble();
      }

      final promedio = suma / resenas.docs.length;

      await _firestore.collection('productos').doc(productoId).update({
        'promedioEstrellas': promedio,
        'totalResenas': resenas.docs.length,
      });
    } catch (e) {
      debugPrint('Error al recalcular promedio: $e');
    }
  }

  // Obtener reseñas de un producto
  Stream<List<Resena>> obtenerResenas(String productoId) {
    return _firestore
        .collection('resenas')
        .where('productoId', isEqualTo: productoId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Resena.fromFirestore(doc)).toList(),
        );
  }

  // Obtener reseña del usuario actual para un producto
  Future<Resena?> obtenerMiResena(String productoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final resena = await _firestore
          .collection('resenas')
          .where('userId', isEqualTo: user.uid)
          .where('productoId', isEqualTo: productoId)
          .get();

      if (resena.docs.isEmpty) return null;

      return Resena.fromFirestore(resena.docs.first);
    } catch (e) {
      debugPrint('Error al obtener mi reseña: $e');
      return null;
    }
  }

  // Obtener productos likeados del usuario
  Future<List<Map<String, dynamic>>> obtenerProductosLikeados() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userDoc = await _firestore
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final productosLikeados = List<String>.from(
        userDoc.data()?['productosLikeados'] ?? [],
      );

      if (productosLikeados.isEmpty) return [];

      // Obtener productos en lotes de 10 (límite de whereIn en Firestore)
      final List<Map<String, dynamic>> productos = [];
      for (var i = 0; i < productosLikeados.length; i += 10) {
        final batch = productosLikeados.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection('productos')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in snapshot.docs) {
          productos.add({'id': doc.id, ...doc.data()});
        }
      }

      return productos;
    } catch (e) {
      debugPrint('Error al obtener productos likeados: $e');
      return [];
    }
  }
}
