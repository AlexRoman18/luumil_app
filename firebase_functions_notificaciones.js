// Este código va en Firebase Functions (Cloud Functions)
// Detecta cuando se aprueba/rechaza una solicitud y crea la notificación automáticamente

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Se ejecuta cuando cambia el campo 'estado' de una solicitud
exports.crearNotificacionAprobacion = functions.firestore
  .document('solicitudes/{solicitudId}')
  .onUpdate(async (change, context) => {
    const antes = change.before.data();
    const despues = change.after.data();
    
    // Solo ejecutar si el estado cambió
    if (antes.estado === despues.estado) {
      return null;
    }
    
    const { userId, email, estado } = despues;
    
    console.log(`Estado cambió a: ${estado} para usuario: ${userId}`);
    
    // Si fue aprobada
    if (estado === 'aprobada') {
      console.log('Creando notificación de aprobación...');
      
      // Actualizar usuario a vendedor
      await admin.firestore().collection('usuarios').doc(userId).set({
        rol: 'vendedor',
        email: email,
        puedeSerVendedor: true,
        fechaAprobacion: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      
      // Crear notificación
      await admin.firestore().collection('notificaciones').add({
        userId: userId,
        tipo: 'solicitud_aprobada',
        titulo: '¡Solicitud aprobada!',
        mensaje: 'Tu solicitud para ser vendedor ha sido aprobada. Ahora puedes empezar a vender tus productos.',
        leida: false,
        fecha: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log('✅ Notificación de aprobación creada');
    }
    
    // Si fue rechazada
    if (estado === 'rechazada') {
      console.log('Creando notificación de rechazo...');
      
      const motivo = despues.motivo || 'No se especificó motivo';
      
      // Actualizar usuario a normal
      await admin.firestore().collection('usuarios').doc(userId).update({
        rol: 'usuario',
      });
      
      // Crear notificación
      await admin.firestore().collection('notificaciones').add({
        userId: userId,
        tipo: 'solicitud_rechazada',
        titulo: 'Solicitud rechazada',
        mensaje: `Tu solicitud para ser vendedor ha sido rechazada. Motivo: ${motivo}`,
        leida: false,
        fecha: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log('✅ Notificación de rechazo creada');
    }
    
    return null;
  });
