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
    'chunhuhub': const LatLng(19.5859, -88.5926),
    'felipe carrillo puerto': const LatLng(19.5808, -88.0450),
    'tihosuco': const LatLng(19.8167, -88.2667),
    'señor': const LatLng(19.6333, -88.1167),
    'tixcacal guardia': const LatLng(20.0667, -88.1167),
    'chan santa cruz': const LatLng(19.5808, -88.0450),
    'x hazil sur': const LatLng(19.3918, -88.0762),
    'x hazil': const LatLng(19.4500, -88.2500),
    'uh may': const LatLng(19.4171, -88.0489),
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
    'x pichil': const LatLng(19.6500, -88.2333),
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

          // Prioridad 1: Ubicación GPS propia del usuario
          final ubicacion = data?['ubicacion'] as Map<String, dynamic>?;
          if (ubicacion != null &&
              ubicacion['latitude'] != null &&
              ubicacion['longitude'] != null) {
            if (mounted) {
              setState(() {
                _center = LatLng(
                  (ubicacion['latitude'] as num).toDouble(),
                  (ubicacion['longitude'] as num).toDouble(),
                );
              });
            }
            return;
          }

          // Prioridad 2: Coordenadas de otro vendedor en la misma comunidad (Firestore)
          final comunidad = data?['comunidad'] as String?;
          if (comunidad != null && comunidad.isNotEmpty) {
            final comunidadNorm = comunidad.toLowerCase().trim();
            final vendedoresSnapshot = await FirebaseFirestore.instance
                .collection('usuarios')
                .where('puedeSerVendedor', isEqualTo: true)
                .get();

            for (final vDoc in vendedoresSnapshot.docs) {
              if (vDoc.id == user.uid) continue;
              final vData = vDoc.data();
              final vComunidad = (vData['comunidad'] as String?) ?? '';
              if (_coincide(comunidadNorm, vComunidad)) {
                final vUbicacion = vData['ubicacion'] as Map<String, dynamic>?;
                if (vUbicacion != null &&
                    vUbicacion['latitude'] != null &&
                    vUbicacion['longitude'] != null) {
                  if (mounted) {
                    setState(() {
                      _center = LatLng(
                        (vUbicacion['latitude'] as num).toDouble(),
                        (vUbicacion['longitude'] as num).toDouble(),
                      );
                    });
                  }
                  return;
                }
              }
            }

            // Prioridad 3: Mapa hardcodeado como último recurso
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

  // ─── Utilidades de búsqueda robusta ───────────────────────────────────────

  /// Normaliza texto: minúsculas, sin acentos, guiones/underscores → espacio,
  /// múltiples espacios colapsados.
  String _norm(String s) {
    const acentos = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    var r = s.toLowerCase().trim();
    acentos.forEach((k, v) => r = r.replaceAll(k, v));
    r = r.replaceAll(RegExp(r'[-_]+'), ' ');
    r = r.replaceAll(RegExp(r'\s+'), ' ');
    return r;
  }

  /// Distancia de Levenshtein (fuzzy matching para errores de tipeo)
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final dp = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );
    for (var i = 0; i <= a.length; i++) dp[i][0] = i;
    for (var j = 0; j <= b.length; j++) dp[0][j] = j;
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        dp[i][j] = a[i - 1] == b[j - 1]
            ? dp[i - 1][j - 1]
            : 1 +
                  [
                    dp[i - 1][j],
                    dp[i][j - 1],
                    dp[i - 1][j - 1],
                  ].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[a.length][b.length];
  }

  /// Coincidencia robusta entre búsqueda y texto.
  /// Acepta: contenido parcial, orden inverso, errores de 1-2 letras.
  bool _coincide(String busqueda, String texto) {
    final b = _norm(busqueda);
    final t = _norm(texto);
    if (t.isEmpty) return false;
    // Exacta o contención
    if (t.contains(b) || b.contains(t)) return true;
    // Palabras individuales de la búsqueda presentes en el texto
    final palabrasB = b.split(' ').where((p) => p.length > 2);
    if (palabrasB.isNotEmpty && palabrasB.every((p) => t.contains(p))) {
      return true;
    }
    // Fuzzy: cada palabra de búsqueda con distancia ≤ 2 a alguna palabra del texto
    final palabrasT = t.split(' ').where((p) => p.length > 2).toList();
    for (final pb in palabrasB) {
      final match = palabrasT.any((pt) {
        final maxDist = pb.length <= 4 ? 1 : 2;
        return _levenshtein(pb, pt) <= maxDist;
      });
      if (match) return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────────

  LatLng? _obtenerCoordenadasPorComunidad(String? comunidad) {
    if (comunidad == null || comunidad.isEmpty) return null;

    final comunidadNormalizada = comunidad.toLowerCase().trim();

    // Buscar con normalización robusta
    final bNorm = _norm(comunidadNormalizada);
    for (var entry in _coordenadasComunidades.entries) {
      if (_coincide(bNorm, entry.key)) return entry.value;
    }
    return null;
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
      final busquedaNormalizada = _comunidadBuscada!.toLowerCase().trim();

      // Traer todos los vendedores
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('puedeSerVendedor', isEqualTo: true)
          .get();

      // Filtrar con matching robusto (acentos, guiones, fuzzy)
      final vendedoresEnComunidad = snapshot.docs.where((doc) {
        final comunidadUsuario = (doc.data()['comunidad'] as String?) ?? '';
        return _coincide(busquedaNormalizada, comunidadUsuario);
      }).toList();

      if (vendedoresEnComunidad.isEmpty) {
        // Nombre capitalizado para el mensaje
        final nombreMostrar = _comunidadBuscada!
            .split(' ')
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
            .join(' ');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aún no hay vendedores en $nombreMostrar'),
              backgroundColor: Colors.grey[700],
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {
            _markers.clear();
            _isLoading = false;
          });
        }
        return;
      }

      // Prioridad 1: usar coordenadas GPS reales del primer vendedor con ubicación
      LatLng? coordenadas;
      String comunidadNombreReal = _comunidadBuscada!;

      for (final doc in vendedoresEnComunidad) {
        final data = doc.data();
        final ubicacion = data['ubicacion'] as Map<String, dynamic>?;
        if (ubicacion != null &&
            ubicacion['latitude'] != null &&
            ubicacion['longitude'] != null) {
          coordenadas = LatLng(
            (ubicacion['latitude'] as num).toDouble(),
            (ubicacion['longitude'] as num).toDouble(),
          );
          comunidadNombreReal =
              data['comunidad'] as String? ?? _comunidadBuscada!;
          break;
        }
      }

      // Prioridad 2: fallback al mapa hardcodeado
      if (coordenadas == null) {
        coordenadas = _obtenerCoordenadasPorComunidad(_comunidadBuscada);
      }

      if (coordenadas == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se encontraron coordenadas para esta comunidad',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Nombre capitalizado
      final nombreComunidad = comunidadNombreReal
          .split(' ')
          .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
          .join(' ');

      final coordenadasFinal = coordenadas;
      // Usar el nombre real de la comunidad (del vendedor en Firestore)
      final nombreParaNavegar = comunidadNombreReal;
      final marker = Marker(
        markerId: MarkerId(busquedaNormalizada),
        position: coordenadasFinal,
        infoWindow: InfoWindow(
          title: nombreComunidad,
          snippet: '🛍 Toca para ver productos',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap: () {
          _mostrarBottomSheetCategorias(context, nombreParaNavegar);
        },
      );

      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.add(marker);
          _isLoading = false;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            mapController.animateCamera(
              CameraUpdate.newLatLngZoom(coordenadasFinal, 14.0),
            );
          }
        });
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

    // Intentar siempre como comunidad primero (usa Firestore + fallback hardcodeado)
    setState(() {
      _comunidadBuscada = busqueda;
    });

    setState(() => _isLoading = true);

    try {
      final busquedaNormalizada = busqueda.toLowerCase().trim();

      // Verificar si hay vendedores con esa comunidad en Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('puedeSerVendedor', isEqualTo: true)
          .get();

      final tieneVendedores = snapshot.docs.any((doc) {
        final comunidadUsuario = (doc.data()['comunidad'] as String?) ?? '';
        return _coincide(busquedaNormalizada, comunidadUsuario);
      });

      if (tieneVendedores) {
        // Es una comunidad con vendedores → mostrar marcador
        _cargarVendedores();
      } else {
        // Sin vendedores en esa comunidad → buscar en productos
        setState(() {
          _comunidadBuscada = null;
          _isLoading = false;
        });
        await _buscarEnProductos(busquedaNormalizada);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarEnProductos(String busqueda) async {
    try {
      final productosSnapshot = await FirebaseFirestore.instance
          .collection('productos')
          .get();

      // Matching robusto en nombre, categoría y descripción
      final productosEncontrados = productosSnapshot.docs.where((doc) {
        final data = doc.data();
        final nombre = (data['nombre'] as String?) ?? '';
        final categoria = (data['categoria'] as String?) ?? '';
        final descripcion = (data['descripcion'] as String?) ?? '';
        return _coincide(busqueda, nombre) ||
            _coincide(busqueda, categoria) ||
            _coincide(busqueda, descripcion);
      }).toList();

      if (productosEncontrados.isNotEmpty) {
        if (!mounted) return;
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se encontraron resultados para "$busqueda"'),
              backgroundColor: Colors.grey[700],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {}
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
