# 📋 Instrucciones para Laravel - Aprobación de Solicitudes de Vendedor

## ⚠️ IMPORTANTE: Cuando apruebas una solicitud de vendedor

Cuando apruebas una solicitud desde tu panel de Laravel, **DEBES** hacer lo siguiente:

### 1️⃣ Actualizar el documento del usuario en Firestore

El código PHP debe:
- Obtener los datos de la solicitud (nombre, descripcion, comunidad, imagenes)
- **Copiar estos datos al perfil del usuario** en la colección `usuarios`
- Actualizar el campo `puedeSerVendedor` a `true`
- Actualizar el campo `rol` a `vendedor`

### 2️⃣ Código PHP actualizado para Laravel

```php
<?php

use Kreait\Firebase\Factory;
use Kreait\Firebase\ServiceAccount;

// Inicializar Firebase Admin SDK (esto ya lo tienes)
$firebase = (new Factory)
    ->withServiceAccount('/ruta/a/tu/firebase-admin-credentials.json')
    ->create();

$firestore = $firebase->createFirestore();
$database = $firestore->database();

/**
 * Aprobar solicitud de vendedor
 * 
 * @param string $solicitudId - ID del documento en la colección 'solicitudes'
 */
function aprobarSolicitud($solicitudId) {
    global $database;
    
    try {
        // 1️⃣ Obtener los datos de la solicitud
        $solicitudRef = $database->collection('solicitudes')->document($solicitudId);
        $solicitud = $solicitudRef->snapshot();
        
        if (!$solicitud->exists()) {
            throw new Exception("La solicitud no existe");
        }
        
        $data = $solicitud->data();
        $userId = $data['userId'];
        $nombre = $data['nombre'] ?? '';
        $descripcion = $data['descripcion'] ?? '';
        
        // 2️⃣ Obtener comunidad del perfil del usuario (ya se guardó en el registro)
        $usuarioRef = $database->collection('usuarios')->document($userId);
        $usuario = $usuarioRef->snapshot();
        $comunidad = $usuario->data()['comunidad'] ?? '';
        
        // 3️⃣ Actualizar el estado de la solicitud a 'aprobada'
        $solicitudRef->update([
            ['path' => 'estado', 'value' => 'aprobada'],
            ['path' => 'fechaAprobacion', 'value' => new \DateTime()]
        ]);
        
        // 4️⃣ ⚠️ PASO CRÍTICO: Actualizar el perfil del usuario con los datos de la solicitud
        // Preparar los datos del perfil (SIN imágenes)
        $perfilData = [
            ['path' => 'puedeSerVendedor', 'value' => true],
            ['path' => 'rol', 'value' => 'vendedor'],
            ['path' => 'nombre', 'value' => $nombre],
            ['path' => 'descripcion', 'value' => $descripcion],
            ['path' => 'fechaAprobacion', 'value' => new \DateTime()],
        ];
        
        $usuarioRef->update($perfilData);
        
        // 5️⃣ Crear notificación para el usuario
        $notificacionRef = $database->collection('notificaciones')->newDocument();
        $notificacionRef->set([
            'userId' => $userId,
            'tipo' => 'solicitud_aprobada',
            'titulo' => '¡Solicitud aprobada!',
            'mensaje' => 'Tu solicitud para ser vendedor ha sido aprobada. Ahora puedes empezar a vender tus productos.',
            'leida' => false,
            'fecha' => new \DateTime(),
        ]);
        
        echo "✅ Solicitud aprobada exitosamente para el usuario: {$userId}\n";
        echo "📝 Perfil actualizado con:\n";
        echo "   - Nombre: {$nombre}\n";
        echo "   - Descripción: {$descripcion}\n";
        echo "   - Comunidad: {$comunidad} (desde perfil del usuario)\n";
        return true;
        
    } catch (Exception $e) {
        echo "❌ Error al aprobar solicitud: " . $e->getMessage() . "\n";
        return false;
    }
}

/**
 * Rechazar solicitud de vendedor
 * 
 * @param string $solicitudId - ID del documento en la colección 'solicitudes'
 * @param string $motivo - Motivo del rechazo
 */
function rechazarSolicitud($solicitudId, $motivo = 'No cumple con los requisitos') {
    global $database;
    
    try {
        // 1️⃣ Obtener los datos de la solicitud
        $solicitudRef = $database->collection('solicitudes')->document($solicitudId);
        $solicitud = $solicitudRef->snapshot();
        
        if (!$solicitud->exists()) {
            throw new Exception("La solicitud no existe");
        }
        
        $data = $solicitud->data();
        $userId = $data['userId'];
        
        // 2️⃣ Actualizar el estado de la solicitud a 'rechazada'
        $solicitudRef->update([
            ['path' => 'estado', 'value' => 'rechazada'],
            ['path' => 'motivoRechazo', 'value' => $motivo],
            ['path' => 'fechaRechazo', 'value' => new \DateTime()]
        ]);
        
        // 3️⃣ Actualizar el rol del usuario a 'usuario' (si lo tenía como 'solicitante')
        $usuarioRef = $database->collection('usuarios')->document($userId);
        $usuarioRef->update([
            ['path' => 'rol', 'value' => 'usuario'],
        ]);
        
        // 4️⃣ Crear notificación para el usuario
        $notificacionRef = $database->collection('notificaciones')->newDocument();
        $notificacionRef->set([
            'userId' => $userId,
            'tipo' => 'solicitud_rechazada',
            'titulo' => 'Solicitud rechazada',
            'mensaje' => "Tu solicitud para ser vendedor ha sido rechazada. Motivo: {$motivo}",
            'leida' => false,
            'fecha' => new \DateTime(),
        ]);
        
        echo "❌ Solicitud rechazada para el usuario: {$userId}\n";
        echo "📝 Motivo: {$motivo}\n";
        
        return true;
        
    } catch (Exception $e) {
        echo "❌ Error al rechazar solicitud: " . $e->getMessage() . "\n";
        return false;
    }
}

// 📌 EJEMPLO DE USO en tu controlador de Laravel:

// Aprobar solicitud
aprobarSolicitud('ID_DE_LA_SOLICITUD_EN_FIRESTORE');

// Rechazar solicitud
rechazarSolicitud('ID_DE_LA_SOLICITUD_EN_FIRESTORE', 'Las imágenes no son claras');

?>
```

## 🔍 Verificación de la estructura de datos

### Colección `solicitudes`
```json
{
  "userId": "abc123",
  "email": "vendedor@example.com",
  "nombre": "Tienda de Juan",
  "descripcion": "Vendemos productos frescos y orgánicos",
  "comunidad": "San Cristóbal",
  "imagenes": [
    "https://res.cloudinary.com/xxx/image1.jpg",
    "https://res.cloudinary.com/xxx/image2.jpg",
   

### Colección `usuarios` (después de aprobar)
```json
{
  "email": "vendedor@example.com",
  "rol": "vendedor",
  "puedeSerVendedor": true,
  "nombre": "Tienda de Juan",
  "descripcion": "Vendemos productos frescos y orgánicos",
  "comunidad": "San Cristóbal",
  "fotoPerfil": "https://res.cloudinary.com/xxx/image1.jpg",
  "fechaAprobacion": "2026-01-24T11:00:00Z",
  "fechaSolicitud": "2026-01-24T10:00:00Z"
}
```
Colección `productos` (creados por el vendedor)
```json
{
  "vendedorId": "abc123",
  "nombre": "Tomates orgánicos",
  "precio": 25.50,
  "descripcion": "Tomates frescos cultivados sin químicos",
  "categoria": "Frutas y Verduras",
  "subcategoria": "Verduras",
  "imagenes": ["url1", "url2"],
  "fecha": "2026-01-24T12:00:00Z"
}
```

## ✅ Checklist de implementación

- [ ] Actualizar código PHP de Laravel con las funciones `aprobarSolicitud()` y `rechazarSolicitud()`
- [ ] Verificar que el Firebase Admin SDK esté correctamente configurado
- [ ] Probar aprobando una solicitud de prueba
- [ ] Verificar en Firebase Console que:
  - El documento en `solicitudes` tiene `estado: "aprobada"`
  - El documento en `usuarios` tiene:
    - `puedeSerVendedor: true`
    - `rol: "vendedor"`
    - `nombre`, `descripcion`, `comunidad` copiados de la solicitud
    - `fotoPerfil` con la primera imagen
  - Se creó un documento en `notificaciones`
- [ ] Verificar en la app Flutter que:
  - El usuario recibe la notificación
  - El perfil muestra los datos correctos
  - Puede cambiar de rol a vendedor
  
## 🎯 Flujo completo

```
1. Usuario llena formulario → Solicitud guardada en Firestore
   ↓
2. Laravel panel de admin → Ve solicitud pendiente
   ↓
3. Admin aprueba → Laravel ejecuta aprobarSolicitud()
   ↓
4. Laravel actualiza:
   - solicitudes/{id}: estado = "aprobada"
   - usuarios/{userId}: nombre, descripcion, comunidad, fotoPerfil, puedeSerVendedor = true
   - notificaciones/{id}: nueva notificación
   ↓
5. Usuario en Flutter:
   - Recibe notificación en tiempo real
   - Puede cambiar a modo vendedor
   - Su perfil ya tiene toda la info
   - Sube productos con su vendedorId
```

## 📝 Notas importantes

1. **Foto de perfil**: Se usa la primera imagen del array de imágenes de la solicitud
2. **Imágenes**: NO se guardan en la solicitud. El vendedor puede agregar su foto de perfil después desde la app Flutter.tual
3. **Edición posterior**: El vendedor puede editar su perfil desde la app Flutter
4. **Historia**: El campo `historia` se puede agregar después desde la app

