// widgets/mapa_ubicacion.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaUbicacion extends StatefulWidget {
  const MapaUbicacion({super.key});

  @override
  State<MapaUbicacion> createState() => _MapaUbicacionState();
}

class _MapaUbicacionState extends State<MapaUbicacion> {
  late GoogleMapController mapController;

  // Coordenadas iniciales (ejemplo: Felipe Carrillo Puerto, QR)
  final LatLng _center = const LatLng(19.5772, -88.0450);

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
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
          myLocationEnabled: true, // muestra tu ubicación
          myLocationButtonEnabled: true, // botón para centrar en tu ubicación
        ),
      ),
    );
  }
}
