import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear notificación cuando se aprueba una solicitud
  static Future<void> enviarNotificacionAprobacion({
    required String userId,
    required String nombreUsuario,
  }) async {
    try {
      print('🔔 Enviando notificación de aprobación a userId: $userId');

      await _firestore.collection('notificaciones').add({
        'userId': userId,
        'tipo': 'solicitud_aprobada',
        'titulo': '¡Solicitud aprobada!',
        'mensaje':
            'Tu solicitud para ser vendedor ha sido aprobada. Ahora puedes empezar a vender tus productos.',
        'leida': false,
        'fecha': FieldValue.serverTimestamp(),
      });

      print('✅ Notificación de aprobación creada exitosamente');
    } catch (e) {
      print('❌ Error al enviar notificación: $e');
    }
  }

  // Crear notificación cuando se rechaza una solicitud
  static Future<void> enviarNotificacionRechazo({
    required String userId,
    required String motivo,
  }) async {
    try {
      await _firestore.collection('notificaciones').add({
        'userId': userId,
        'tipo': 'solicitud_rechazada',
        'titulo': 'Solicitud rechazada',
        'mensaje':
            'Tu solicitud para ser vendedor ha sido rechazada. Motivo: $motivo',
        'leida': false,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al enviar notificación: $e');
    }
  }
}
