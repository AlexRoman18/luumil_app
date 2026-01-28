// widgets/mapa_ubicacion.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luumil_app/screens/usuario/productos_comunidad_screen.dart';

class MapaUbicacion extends StatefulWidget {
  final Function(String)? onSearch;

  const MapaUbicacion({super.key, this.onSearch});

  @override
  State<MapaUbicacion> createState() => _MapaUbicacionState();
}

class _MapaUbicacionState extends State<MapaUbicacion> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = false;
  String? _comunidadBuscada;

  // Coordenadas iniciales (ejemplo: Felipe Carrillo Puerto, QR)
  LatLng _center = const LatLng(19.5772, -88.0450);

  // Mapa de comunidades con sus coordenadas precisas
  final Map<String, LatLng> _coordenadasComunidades = {
    // Comunidades principales de Quintana Roo
    'chunhuhub': const LatLng(19.4167, -88.6167),
    'felipe carrillo puerto': const LatLng(19.5808, -88.0450),
    'tihosuco': const LatLng(19.8167, -88.2667),
    'señor': const LatLng(19.6333, -88.1167),
    'tixcacal guardia': const LatLng(20.0667, -88.1167),
    'chan santa cruz': const LatLng(19.5808, -88.0450),
    'xhazil sur': const LatLng(19.4500, -88.2500),
    'xhazil': const LatLng(19.4500, -88.2500),
    'chancah veracruz': const LatLng(19.6833, -88.0833),
    'tepich': const LatLng(19.8833, -88.3167),
    'polyuc': const LatLng(19.7000, -88.2000),
    'noh bec': const LatLng(18.9833, -88.1167),
    'sacalaca': const LatLng(18.9000, -88.0500),
    'jose maria morelos': const LatLng(19.7333, -88.7167),
    'sabán': const LatLng(19.8167, -88.5833),
    'kampocolche': const LatLng(19.6167, -88.3833),
    'chumpón': const LatLng(19.5500, -88.1833),
    'dzulá': const LatLng(19.7667, -88.4167),
    'san silverio': const LatLng(19.4833, -88.8167),
    'presidente juárez': const LatLng(19.5000, -88.5000),
    'x-pichil': const LatLng(19.6500, -88.2333),
    'san antonio tuk': const LatLng(19.7167, -88.1667),
    'betania': const LatLng(19.6000, -88.2667),
    'tulum': const LatLng(20.2114, -87.4289),
    'playa del carmen': const LatLng(20.6296, -87.0739),
    'cancún': const LatLng(21.1619, -86.8515),
    'chetumal': const LatLng(18.5001, -88.2960),
    'bacalar': const LatLng(18.6781, -88.3953),
    'cozumel': const LatLng(20.5083, -86.9458),
  };

  @override
  void initState() {
    super.initState();
    _cargarUbicacionUsuario();
  }

  /// Cargar ubicación del usuario actual para centrar el mapa
  Future<void> _cargarUbicacionUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data();

          // Prioridad 1: Ubicación GPS precisa
          final ubicacion = data?['ubicacion'] as Map<String, dynamic>?;
          if (ubicacion != null &&
              ubicacion['latitude'] != null &&
              ubicacion['longitude'] != null) {
            setState(() {
              _center = LatLng(ubicacion['latitude'], ubicacion['longitude']);
            });
            return;
          }

          // Prioridad 2: Comunidad
          final comunidad = data?['comunidad'] as String?;
          if (comunidad != null) {
            final coordenadas = _obtenerCoordenadasPorComunidad(comunidad);
            if (coordenadas != null && mounted) {
              setState(() {
                _center = coordenadas;
              });
            }
          }
        }
      }
    } catch (e) {
      // Si hay error, usar ubicación por defecto
    }
  }

  LatLng? _obtenerCoordenadasPorComunidad(String? comunidad) {
    if (comunidad == null || comunidad.isEmpty) return null;

    final comunidadNormalizada = comunidad.toLowerCase().trim();

    // Buscar coincidencia exacta
    if (_coordenadasComunidades.containsKey(comunidadNormalizada)) {
      return _coordenadasComunidades[comunidadNormalizada];
    }

    // Buscar coincidencia parcial
    for (var entry in _coordenadasComunidades.entries) {
      if (comunidadNormalizada.contains(entry.key) ||
          entry.key.contains(comunidadNormalizada)) {
        return entry.value;
      }
    }

    // Si no se encuentra, usar coordenadas por defecto con pequeña variación
    return LatLng(
      _center.latitude + (comunidadNormalizada.hashCode % 100) / 1000,
      _center.longitude + (comunidadNormalizada.hashCode % 100) / 1000,
    );
  }

  Future<void> _cargarVendedores() async {
    if (_comunidadBuscada == null || _comunidadBuscada!.isEmpty) {
      setState(() {
        _markers.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Normalizar búsqueda
      final comunidadNormalizada = _comunidadBuscada!.toLowerCase().trim();

      // Buscar en las comunidades predefinidas
      String? comunidadEncontrada;
      LatLng? coordenadas;

      for (var entry in _coordenadasComunidades.entries) {
        if (entry.key.contains(comunidadNormalizada) ||
            comunidadNormalizada.contains(entry.key)) {
          comunidadEncontrada = entry.key;
          coordenadas = entry.value;
          break;
        }
      }

      if (coordenadas == null) {
        // Comunidad no encontrada
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comunidad no encontrada'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Verificar si hay vendedores en esta comunidad
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .get();

      // Buscar vendedores que coincidan con la comunidad (normalizada)
      final tieneVendedores = snapshot.docs.any((doc) {
        final data = doc.data();
        final comunidadUsuario = data['comunidad'] as String?;
        if (comunidadUsuario == null) return false;

        final comunidadUsuarioNormalizada = comunidadUsuario
            .toLowerCase()
            .trim();
        return (comunidadUsuarioNormalizada == comunidadEncontrada ||
                comunidadUsuarioNormalizada.contains(comunidadEncontrada!) ||
                comunidadEncontrada.contains(comunidadUsuarioNormalizada)) &&
            (data['puedeSerVendedor'] == true);
      });

      // Nombre capitalizado
      final nombreComunidad = comunidadEncontrada!
          .split(' ')
          .map(
            (word) =>
                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
          )
          .join(' ');

      // Crear marcador solo si tiene vendedores
      if (tieneVendedores) {
        final marker = Marker(
          markerId: MarkerId(comunidadEncontrada),
          position: coordenadas,
          infoWindow: InfoWindow(
            title: nombreComunidad,
            snippet: '🛒 Toca para ver productos',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            _mostrarBottomSheetCategorias(context, _comunidadBuscada!);
          },
        );

        if (mounted) {
          setState(() {
            _markers.clear();
            _markers.add(marker);
            _isLoading = false;
          });

          // Centrar cámara en el marcador
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              mapController.animateCamera(
                CameraUpdate.newLatLngZoom(coordenadas!, 14.0),
              );
            }
          });
        }
      } else {
        // No hay vendedores en esta comunidad
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aún no hay vendedores en $nombreComunidad'),
              backgroundColor: Colors.grey[700],
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {
            _markers.clear();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void buscarComunidad(String busqueda) async {
    if (busqueda.isEmpty) {
      setState(() {
        _comunidadBuscada = null;
        _markers.clear();
      });
      return;
    }

    final busquedaNormalizada = busqueda.toLowerCase().trim();

    // Primero intentar buscar como comunidad
    final esComunidad = _coordenadasComunidades.keys.any(
      (comunidad) =>
          comunidad.contains(busquedaNormalizada) ||
          busquedaNormalizada.contains(comunidad),
    );

    if (esComunidad) {
      // Es una comunidad, mostrar marcador
      setState(() {
        _comunidadBuscada = busqueda;
      });
      _cargarVendedores();
      return;
    }

    // Si no es comunidad, buscar en productos
    await _buscarEnProductos(busquedaNormalizada);
  }

  Future<void> _buscarEnProductos(String busqueda) async {
    try {
      // Buscar productos que contengan el término en su nombre o categoría
      final productosSnapshot = await FirebaseFirestore.instance
          .collection('productos')
          .get();

      final productosEncontrados = productosSnapshot.docs.where((doc) {
        final data = doc.data();
        final nombre = (data['nombre'] as String?)?.toLowerCase() ?? '';
        final categoria = (data['categoria'] as String?)?.toLowerCase() ?? '';

        return nombre.contains(busqueda) || categoria.contains(busqueda);
      }).toList();

      if (productosEncontrados.isNotEmpty) {
        // Navegar a pantalla de resultados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductosComunidadScreen(
              comunidad: 'Resultados de búsqueda',
              terminoBusqueda: busqueda,
            ),
          ),
        );
      } else {
        // No se encontró nada
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontraron productos para "$busqueda"'),
              backgroundColor: Colors.grey[700],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Error en búsqueda
    }
  }

  void _mostrarBottomSheetCategorias(BuildContext context, String comunidad) {
    final categorias = [
      {'nombre': 'Ver todo', 'icono': Icons.apps_outlined},
      {'nombre': 'Dulces', 'icono': Icons.cake_outlined},
      {'nombre': 'Verduras', 'icono': Icons.eco_outlined},
      {'nombre': 'Frutas', 'icono': Icons.apple},
      {'nombre': 'Limpieza', 'icono': Icons.cleaning_services_outlined},
      {'nombre': 'Zapatos', 'icono': Icons.checkroom_outlined},
      {'nombre': 'Otros', 'icono': Icons.more_horiz},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título
            Text(
              comunidad,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona una categoría',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Grid de categorías
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final cat = categorias[index];
                final esVerTodo = cat['nombre'] == 'Ver todo';

                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductosComunidadScreen(
                          comunidad: comunidad,
                          categoria: esVerTodo ? null : cat['nombre'] as String,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: esVerTodo ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: esVerTodo ? Colors.blue : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat['icono'] as IconData,
                          size: 18,
                          color: esVerTodo ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['nombre'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: esVerTodo
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: esVerTodo ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250, // Aumentado para dar espacio al icono
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        clipBehavior: Clip.none, // Permite que el icono sobresalga
        children: [
          // Mapa
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.white.withOpacity(0.8),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  // Botón de ayuda en la esquina superior izquierda
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => _mostrarAyuda(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.help_outline,
                          size: 20,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('Cómo usar el mapa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAyudaItem(
              Icons.location_on,
              'Buscar por comunidad',
              'Escribe el nombre de una comunidad (ej: "Tulum"). Aparecerá un marcador azul en el mapa. Al tocarlo, se abrirá un menú con categorías donde podrás elegir "Ver todo" o filtrar por tipo de producto.',
            ),
            const SizedBox(height: 12),
            _buildAyudaItem(
              Icons.shopping_basket,
              'Buscar por producto',
              'Escribe el nombre de un producto (ej: "Plátano") para verlo en todas las comunidades.',
            ),
            const SizedBox(height: 12),
            _buildAyudaItem(
              Icons.category,
              'Buscar por categoría',
              'Escribe una categoría (ej: "Frutas") para ver todos los productos de ese tipo.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildAyudaItem(IconData icon, String titulo, String descripcion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                descripcion,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
