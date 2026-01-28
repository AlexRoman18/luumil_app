import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarritoItem {
  final String productoId;
  final String nombre;
  final String precio;
  final String? imagen;
  final String categoria;
  final String vendedorId;
  final String nombreTienda;
  final String? comunidadVendedor;
  int cantidad;

  CarritoItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    this.imagen,
    required this.categoria,
    required this.vendedorId,
    required this.nombreTienda,
    this.comunidadVendedor,
    this.cantidad = 1,
  });

  double get precioNumerico {
    try {
      return double.parse(precio.replaceAll(RegExp(r'[^\d.]'), ''));
    } catch (e) {
      return 0.0;
    }
  }

  double get subtotal => precioNumerico * cantidad;

  // Convertir a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'vendedorId': vendedorId,
      'nombreTienda': nombreTienda,
      'comunidadVendedor': comunidadVendedor,
      'cantidad': cantidad,
    };
  }

  // Crear desde Map de Firebase
  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      productoId: map['productoId'] ?? '',
      nombre: map['nombre'] ?? 'Sin nombre',
      precio: map['precio']?.toString() ?? '0',
      imagen: map['imagen'],
      categoria: map['categoria'] ?? 'Sin categoría',
      vendedorId: map['vendedorId'] ?? '',
      nombreTienda: map['nombreTienda'] ?? 'Tienda',
      comunidadVendedor: map['comunidadVendedor'],
      cantidad: map['cantidad'] ?? 1,
    );
  }
}

class CarritoService extends ChangeNotifier {
  static final CarritoService _instance = CarritoService._internal();
  factory CarritoService() => _instance;
  CarritoService._internal() {
    _cargarCarrito();
  }

  final List<CarritoItem> _items = [];
  bool _cargado = false;

  List<CarritoItem> get items => List.unmodifiable(_items);

  int get cantidadTotal => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // Cargar carrito desde Firebase
  Future<void> _cargarCarrito() async {
    if (_cargado) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('carritos')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final itemsData = data?['items'] as List?;

        if (itemsData != null) {
          _items.clear();
          for (var itemMap in itemsData) {
            _items.add(CarritoItem.fromMap(itemMap as Map<String, dynamic>));
          }
          notifyListeners();
        }
      }

      _cargado = true;
    } catch (e) {
      debugPrint('Error al cargar carrito: $e');
    }
  }

  // Guardar carrito en Firebase
  Future<void> _guardarCarrito() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('carritos')
          .doc(user.uid)
          .set({
            'items': _items.map((item) => item.toMap()).toList(),
            'fechaActualizacion': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error al guardar carrito: $e');
    }
  }

  void agregarProducto(Map<String, dynamic> producto) async {
    final productoId = producto['id'] ?? '';

    if (productoId.isEmpty) return;

    // Verificar si el producto ya está en el carrito
    final index = _items.indexWhere((item) => item.productoId == productoId);

    if (index >= 0) {
      // Si ya existe, incrementar cantidad
      _items[index].cantidad++;
    } else {
      // Si no existe, agregarlo
      final imagenes = producto['imagenes'] as List?;
      _items.add(
        CarritoItem(
          productoId: productoId,
          nombre: producto['nombre'] ?? 'Sin nombre',
          precio: producto['precio']?.toString() ?? '0',
          imagen: imagenes != null && imagenes.isNotEmpty ? imagenes[0] : null,
          categoria: producto['categoria'] ?? 'Sin categoría',
          vendedorId: producto['vendedorId'] ?? '',
          nombreTienda: producto['nombreTienda'] ?? 'Tienda',
          comunidadVendedor: producto['comunidadVendedor'],
        ),
      );
    }

    notifyListeners();
    await _guardarCarrito();
  }

  void incrementarCantidad(String productoId) async {
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index >= 0) {
      _items[index].cantidad++;
      notifyListeners();
      await _guardarCarrito();
    }
  }

  void decrementarCantidad(String productoId) async {
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index >= 0) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      await _guardarCarrito();
    }
  }

  void eliminarProducto(String productoId) async {
    _items.removeWhere((item) => item.productoId == productoId);
    notifyListeners();
    await _guardarCarrito();
  }

  void vaciarCarrito() async {
    _items.clear();
    notifyListeners();
    await _guardarCarrito();
  }
}
