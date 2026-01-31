import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luumil_app/auth/auth_service.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/services/google_auth_service.dart';
import 'package:luumil_app/widgets/usuario/custom_text_field.dart';
import 'package:luumil_app/widgets/usuario/seleccionar_ubicacion_mapa.dart';
import '../../screens/usuario/iniciarsesion_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController comunidadController = TextEditingController();
  final AuthService authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  LatLng? _ubicacionSeleccionada;
  String _comunidadSeleccionada = '';

  final List<String> _comunidades = [
    'Mi ubicación',
    'Chunhuhub',
    'Felipe Carrillo Puerto',
    'Tihosuco',
    'Señor',
    'Tixcacal Guardia',
    'Chan Santa Cruz',
    'Xhazil Sur',
    'Xhazil',
    'Chancah Veracruz',
    'Tepich',
    'Polyuc',
    'Noh Bec',
    'Sacalaca',
    'José María Morelos',
    'Sabán',
    'Kampocolche',
    'Chumpón',
    'Dzulá',
    'San Silverio',
    'Presidente Juárez',
    'X-Pichil',
    'San Antonio Tuk',
    'Betania',
    'Tulum',
    'Playa del Carmen',
    'Cancún',
    'Chetumal',
    'Bacalar',
    'Cozumel',
  ];

  // Mapa de comunidades con sus coordenadas
  final Map<String, LatLng> _coordenadasComunidades = {
    'Chunhuhub': const LatLng(19.4167, -88.6167),
    'Felipe Carrillo Puerto': const LatLng(19.5808, -88.0450),
    'Tihosuco': const LatLng(19.8167, -88.2667),
    'Señor': const LatLng(19.6333, -88.1167),
    'Tixcacal Guardia': const LatLng(20.0667, -88.1167),
    'Chan Santa Cruz': const LatLng(19.5808, -88.0450),
    'Xhazil Sur': const LatLng(19.4500, -88.2500),
    'Xhazil': const LatLng(19.4500, -88.2500),
    'Chancah Veracruz': const LatLng(19.6833, -88.0833),
    'Tepich': const LatLng(19.8833, -88.3167),
    'Polyuc': const LatLng(19.7000, -88.2000),
    'Noh Bec': const LatLng(18.9833, -88.1167),
    'Sacalaca': const LatLng(18.9000, -88.0500),
    'José María Morelos': const LatLng(19.7333, -88.7167),
    'Sabán': const LatLng(19.8167, -88.5833),
    'Kampocolche': const LatLng(19.6167, -88.3833),
    'Chumpón': const LatLng(19.5500, -88.1833),
    'Dzulá': const LatLng(19.7667, -88.4167),
    'San Silverio': const LatLng(19.4833, -88.8167),
    'Presidente Juárez': const LatLng(19.5000, -88.5000),
    'X-Pichil': const LatLng(19.6500, -88.2333),
    'San Antonio Tuk': const LatLng(19.7167, -88.1667),
    'Betania': const LatLng(19.6000, -88.2667),
    'Tulum': const LatLng(20.2114, -87.4289),
    'Playa del Carmen': const LatLng(20.6296, -87.0739),
    'Cancún': const LatLng(21.1619, -86.8515),
    'Chetumal': const LatLng(18.5001, -88.2960),
    'Bacalar': const LatLng(18.6781, -88.3953),
    'Cozumel': const LatLng(20.5083, -86.9458),
  };

  // Calcular distancia entre dos puntos usando fórmula de Haversine
  double _calcularDistancia(LatLng punto1, LatLng punto2) {
    const double radioTierra = 6371; // km
    final double dLat = _gradosARadianes(punto2.latitude - punto1.latitude);
    final double dLng = _gradosARadianes(punto2.longitude - punto1.longitude);

    final double a =
        (dLat / 2).abs() * (dLat / 2).abs() +
        (punto1.latitude * 3.14159 / 180).abs() *
            (punto2.latitude * 3.14159 / 180).abs() *
            (dLng / 2).abs() *
            (dLng / 2).abs();

    final double c = 2 * (a.abs().clamp(0.0, 1.0)).abs();
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * 3.14159 / 180;
  }

  // Encontrar la comunidad más cercana a una ubicación GPS
  String _encontrarComunidadCercana(LatLng ubicacion) {
    String comunidadCercana = 'Felipe Carrillo Puerto'; // Por defecto
    double distanciaMinima = double.infinity;

    for (var entry in _coordenadasComunidades.entries) {
      final distancia = _calcularDistancia(ubicacion, entry.value);
      if (distancia < distanciaMinima) {
        distanciaMinima = distancia;
        comunidadCercana = entry.key;
      }
    }

    return comunidadCercana;
  }

  Future<void> registerUser() async {
    final nombre = nombreController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final comunidad = _comunidadSeleccionada.isEmpty
        ? comunidadController.text.trim()
        : _comunidadSeleccionada;

    // Validaciones mínimas
    if (nombre.isEmpty) {
      _showMessage("Ingrese su nombre");
      return;
    }

    if (email.isEmpty) {
      _showMessage("Ingrese un correo electrónico");
      return;
    }

    if (password.length < 6) {
      _showMessage("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (comunidad.isEmpty) {
      _showMessage("Seleccione o ingrese su comunidad");
      return;
    }

    try {
      // Registrar usuario con ubicación si fue seleccionada
      await authService.registerWithEmailPassword(
        email,
        password,
        nombre,
        comunidad,
        ubicacion: _ubicacionSeleccionada,
      );

      // Cerrar todas las pantallas y volver a AuthGate
      if (mounted) {
        // Cerrar pantallas hasta llegar a la raíz (AuthGate)
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showMessage("Error inesperado al registrarse");
    }
  }

  Future<void> _seleccionarComunidad() async {
    final seleccion = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Selecciona tu comunidad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _comunidades.length,
                itemBuilder: (context, index) {
                  final comunidad = _comunidades[index];
                  final esMiUbicacion = comunidad == 'Mi ubicación';

                  return ListTile(
                    leading: Icon(
                      esMiUbicacion ? Icons.my_location : Icons.location_on,
                      color: esMiUbicacion
                          ? const Color(0xFF007BFF)
                          : Colors.grey[600],
                    ),
                    title: Text(
                      comunidad,
                      style: TextStyle(
                        fontWeight: esMiUbicacion
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: esMiUbicacion
                            ? const Color(0xFF007BFF)
                            : Colors.black87,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, comunidad),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (seleccion != null) {
      if (seleccion == 'Mi ubicación') {
        // Abrir mapa de selección
        final ubicacion = await Navigator.push<LatLng>(
          context,
          MaterialPageRoute(
            builder: (context) => SeleccionarUbicacionMapa(
              ubicacionInicial: _ubicacionSeleccionada,
            ),
          ),
        );

        if (ubicacion != null && mounted) {
          // Encontrar la comunidad más cercana a las coordenadas GPS
          final comunidadCercana = _encontrarComunidadCercana(ubicacion);

          setState(() {
            _ubicacionSeleccionada = ubicacion;
            _comunidadSeleccionada = comunidadCercana;
            comunidadController.text = comunidadCercana;
          });
        }
      } else {
        setState(() {
          _comunidadSeleccionada = seleccion;
          comunidadController.text = seleccion;
          _ubicacionSeleccionada =
              null; // Limpiar ubicación GPS si selecciona comunidad
        });
      }
    }
  }

  void _handleFirebaseError(FirebaseAuthException e) {
    String message = "Error al registrarse";

    switch (e.code) {
      case 'email-already-in-use':
        message = "Este correo ya está registrado";
        break;
      case 'invalid-email':
        message = "El correo no tiene un formato válido";
        break;
      case 'weak-password':
        message = "La contraseña es muy débil";
        break;
    }

    _showMessage(message);
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final userCredential = await _googleAuthService.signInWithGoogle();

      if (userCredential == null) {
        // Usuario canceló el inicio de sesión
        return;
      }

      // El registro fue exitoso, Firebase Auth se encargará de la navegación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso con Google!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrarse con Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.70,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                CustomTextField(
                  hint: 'Nombre',
                  icon: Icons.person,
                  controller: nombreController,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hint: 'Correo electrónico',
                  icon: Icons.email,
                  controller: emailController,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hint: 'Contraseña',
                  icon: Icons.lock,
                  obscure: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _seleccionarComunidad,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      hint: 'Comunidad',
                      icon: Icons.location_on,
                      controller: comunidadController,
                    ),
                  ),
                ),

                // Advertencia si no se usa ubicación GPS
                if (comunidadController.text.isNotEmpty &&
                    _ubicacionSeleccionada == null)
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber[300]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.priority_high,
                          color: Colors.amber[700],
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Para una ubicación más precisa en el mapa, selecciona "Mi ubicación"',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[900],
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidó su contraseña?',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón Google
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset(
                      'assets/icons/buscar.png',
                      width: 20,
                      height: 20,
                    ),
                    label: const Text(
                      'Registrarme con Google',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tiene cuenta?'),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text(
                        'Inicie sesión',
                        style: TextStyle(
                          color: Color(0xFF007BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
