import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProductoService {
  static Future<void> guardarProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    required List<String> fotos,
    int stock = 0,
  }) async {
    final producto = {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'fotos': fotos,
      'stock': stock,
      'fecha': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('productos').add(producto);
  }
}
