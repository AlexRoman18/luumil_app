import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SolicitudButton extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final List<String> imagenes;
  final bool Function()? onValidate;

  const SolicitudButton({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.imagenes,
    this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () async {
          // ✅ VALIDAR CAMPOS PRIMERO
          if (onValidate != null && !onValidate!()) {
            return; // No continuar si la validación falla
          }

          // Obtener usuario actual de Firebase Auth
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Debes iniciar sesión primero"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          try {
            // ✅ Verificar si ya existe una solicitud pendiente
            final solicitudesExistentes = await firestore
                .collection("solicitudes")
                .where("userId", isEqualTo: user.uid)
                .where("estado", isEqualTo: "pendiente")
                .limit(1)
                .get();

            if (solicitudesExistentes.docs.isNotEmpty) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Ya has enviado una solicitud. Estamos revisándola.",
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );

              // Volver al home de forma segura
              Future.microtask(() {
                if (context.mounted) {
                  int popCount = 0;
                  Navigator.of(context).popUntil((route) {
                    popCount++;
                    return route.isFirst || popCount > 10;
                  });
                }
              });
              return;
            }

            // Obtener comunidad del perfil del usuario
            final userDoc = await firestore
                .collection('usuarios')
                .doc(user.uid)
                .get();
            final comunidad = userDoc.data()?['comunidad'] ?? '';

            // Guardar solicitud con userId (sin imágenes)
            await firestore.collection("solicitudes").add({
              "userId": user.uid,
              "email": user.email ?? '',
              "nombre": nombre,
              "descripcion": descripcion,
              "comunidad": comunidad,
              "estado": "pendiente",
              "fecha": FieldValue.serverTimestamp(),
            });

            // Actualizar estado del usuario a 'solicitante'
            await firestore.collection('usuarios').doc(user.uid).set({
              'rol': 'solicitante',
              'email': user.email ?? '',
              'fechaSolicitud': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            if (!context.mounted) return;

            // ✅ Mostrar diálogo amigable de confirmación
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '¡Solicitud enviada!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu solicitud para ser vendedor ha sido enviada exitosamente.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Te notificaremos en la campanita 🔔 cuando sea revisada',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );

            // Luego navegar de forma segura
            // Cerrar hasta 10 pantallas (suficiente para llegar al home)
            Future.microtask(() {
              if (context.mounted) {
                int popCount = 0;
                Navigator.of(context).popUntil((route) {
                  popCount++;
                  return route.isFirst || popCount > 10;
                });
              }
            });
          } catch (e) {
            print('❌ Error al enviar solicitud: $e');

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error al enviar solicitud: $e"),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Enviar solicitud',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
