// widgets/mapa_ubicacion.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luumil_app/screens/usuario/tienda_perfil_screen.dart';

class MapaUbicacion extends StatefulWidget {
  const MapaUbicacion({super.key});

  @override
  State<MapaUbicacion> createState() => _MapaUbicacionState();
}

class _MapaUbicacionState extends State<MapaUbicacion> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

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
    _cargarVendedores();
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
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('puedeSerVendedor', isEqualTo: true)
          .get();

      final markers = <Marker>{};
      int contador = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Primero intentar obtener ubicación exacta
        final ubicacion = data['ubicacion'] as Map<String, dynamic>?;
        LatLng? coordenadas;

        if (ubicacion != null &&
            ubicacion['latitude'] != null &&
            ubicacion['longitude'] != null) {
          // Usar ubicación exacta si existe
          coordenadas = LatLng(ubicacion['latitude'], ubicacion['longitude']);
        } else {
          // Fallback a comunidad si no hay ubicación exacta
          final comunidad = data['comunidad'] as String?;
          coordenadas = _obtenerCoordenadasPorComunidad(comunidad);

          if (coordenadas != null) {
            // Agregar pequeña variación si hay múltiples vendedores en la misma comunidad
            final offset = contador * 0.002;
            coordenadas = LatLng(
              coordenadas.latitude + offset,
              coordenadas.longitude + offset,
            );
          }
        }

        if (coordenadas != null) {
          final marker = Marker(
            markerId: MarkerId(doc.id),
            position: coordenadas,
            infoWindow: InfoWindow(
              title:
                  data['nombreTienda'] ?? data['nombrePersonal'] ?? 'Vendedor',
              snippet: '📍 Toca para ver perfil',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            onTap: () {
              // Navegar al perfil de la tienda
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TiendaPerfilScreen(vendedorId: doc.id),
                ),
              );
            },
          );
          markers.add(marker);
          contador++;
        }
      }

      if (mounted) {
        setState(() {
          _markers.addAll(markers);
          _isLoading = false;
        });

        // Si hay marcadores, ajustar la cámara para mostrarlos
        if (markers.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _ajustarCamara(markers);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _ajustarCamara(Set<Marker> markers) {
    if (markers.isEmpty) return;

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng)
        minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng)
        maxLng = marker.position.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(vertical: 20),
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
          ],
        ),
      ),
    );
  }
}
