import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class SeleccionarUbicacionMapa extends StatefulWidget {
  final LatLng? ubicacionInicial;

  const SeleccionarUbicacionMapa({super.key, this.ubicacionInicial});

  @override
  State<SeleccionarUbicacionMapa> createState() =>
      _SeleccionarUbicacionMapaState();
}

class _SeleccionarUbicacionMapaState extends State<SeleccionarUbicacionMapa> {
  late GoogleMapController _mapController;
  LatLng? _ubicacionSeleccionada;
  bool _cargando = false;

  // Coordenadas por defecto (Felipe Carrillo Puerto)
  final LatLng _defaultLocation = const LatLng(19.5808, -88.0450);

  @override
  void initState() {
    super.initState();
    _ubicacionSeleccionada = widget.ubicacionInicial ?? _defaultLocation;
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _cargando = true);

    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _cargando = false);

        if (mounted) {
          final activar = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.orange[700], size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'GPS desactivado',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Para obtener tu ubicación automáticamente, necesitas activar el GPS de tu dispositivo.\n\n¿Deseas activarlo ahora?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Activar GPS',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
          );

          if (activar == true) {
            // Abrir configuración de ubicación
            await Geolocator.openLocationSettings();

            // Mostrar mensaje indicando que debe volver después de activar
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '📍 Activa el GPS y presiona nuevamente el botón "Mi ubicación"',
                  ),
                  backgroundColor: Color(0xFF007BFF),
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        }
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Permiso de ubicación denegado'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _cargando = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _cargando = false);

        if (mounted) {
          final abrirConfig = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Permiso denegado',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Has denegado permanentemente el permiso de ubicación.\n\nPara usar esta función, debes habilitarlo manualmente en la configuración de la aplicación.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ir a Configuración',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            ),
          );

          if (abrirConfig == true) {
            await Geolocator.openAppSettings();
          }
        }
        return;
      }

      // Obtener ubicación con timeout más amplio (el GPS necesita tiempo para inicializarse)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      final nuevaUbicacion = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _ubicacionSeleccionada = nuevaUbicacion;
          _cargando = false;
        });

        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(nuevaUbicacion, 16),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ubicación obtenida correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⏱️ El GPS está tardando en obtener señal. Espera unos segundos e intenta de nuevo, o selecciona manualmente en el mapa',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
      setState(() => _cargando = false);
    } on LocationServiceDisabledException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ El GPS sigue desactivado. Por favor, actívalo en la configuración',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      setState(() => _cargando = false);
    } catch (e) {
      if (mounted) {
        // Mensaje más amigable para otros errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ℹ️ No se pudo obtener la ubicación GPS automáticamente. Puedes seleccionar tu ubicación manualmente tocando en el mapa.\n\nError: ${e.toString()}',
            ),
            backgroundColor: Colors.blue[700],
            duration: const Duration(seconds: 6),
          ),
        );
      }
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar Ubicación',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _ubicacionSeleccionada!,
              zoom: 15,
            ),
            onTap: (position) {
              setState(() {
                _ubicacionSeleccionada = position;
              });
            },
            markers: _ubicacionSeleccionada != null
                ? {
                    Marker(
                      markerId: const MarkerId('ubicacion_seleccionada'),
                      position: _ubicacionSeleccionada!,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() {
                          _ubicacionSeleccionada = newPosition;
                        });
                      },
                    ),
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Indicador de carga
          if (_cargando)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Instrucciones
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF007BFF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toca el mapa o arrastra el marcador para seleccionar tu ubicación',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de mi ubicación
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: Colors.white,
              onPressed: _obtenerUbicacionActual,
              child: const Icon(Icons.my_location, color: Color(0xFF007BFF)),
            ),
          ),

          // Botón de confirmar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                if (_ubicacionSeleccionada != null) {
                  Navigator.pop(context, _ubicacionSeleccionada);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                'Confirmar Ubicación',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
