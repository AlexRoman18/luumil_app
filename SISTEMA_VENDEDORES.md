# Sistema de Gestión de Vendedores - Luumil App

## 📋 Descripción General

Este sistema permite a los usuarios solicitar convertirse en vendedores y gestionar sus productos. El flujo incluye:

1. **Solicitud de vendedor** - Los usuarios envían una solicitud desde la app
2. **Aprobación desde panel admin** - Los administradores aprueban/rechazan solicitudes
3. **Notificaciones in-app** - Los usuarios reciben notificaciones cuando su solicitud es procesada
4. **Cambio de roles** - Los vendedores pueden alternar entre modo vendedor y usuario

---

## 🔄 Flujo Completo

### 1️⃣ Usuario Solicita Ser Vendedor

**Ubicación:** `lib/widgets/comer/no-reutilizable/solicitud_button.dart`

Cuando el usuario llena el formulario y presiona "Enviar solicitud":

```dart
// Se guarda en Firestore
collection: solicitudes
{
  userId: "uid_del_usuario",
  email: "usuario@email.com",
  nombre: "Nombre del negocio",
  descripcion: "Productos que vende",
  comunidad: "San Antonio Semetabaj",
  estado: "pendiente",
  imagenes: ["url1", "url2"],
  fecha: timestamp
}

// Se actualiza el rol del usuario
collection: usuarios / doc: userId
{
  rol: "solicitante",
  email: "usuario@email.com",
  fechaSolicitud: timestamp
}
```

**Resultado:** El usuario es redirigido al dashboard con mensaje de éxito.

---

### 2️⃣ Administrador Procesa Solicitud

**Panel de Administración** (tu panel web)

**Para APROBAR una solicitud:**

```javascript
// Actualizar la solicitud
await db.collection('solicitudes').doc(solicitudId).update({
  estado: 'aprobada',
  fechaRespuesta: FieldValue.serverTimestamp()
});

// Actualizar el rol del usuario
await db.collection('usuarios').doc(userId).update({
  rol: 'vendedor'
});

// Crear notificación in-app
await db.collection('notificaciones').add({
  userId: userId,
  tipo: 'solicitud_aprobada',
  titulo: '¡Solicitud aprobada!',
  mensaje: 'Tu solicitud para ser vendedor ha sido aprobada. Ahora puedes empezar a vender tus productos.',
  leida: false,
  fecha: FieldValue.serverTimestamp()
});
```

**Para RECHAZAR una solicitud:**

```javascript
// Actualizar la solicitud
await db.collection('solicitudes').doc(solicitudId).update({
  estado: 'rechazada',
  fechaRespuesta: FieldValue.serverTimestamp()
});

// Actualizar el rol del usuario
await db.collection('usuarios').doc(userId).update({
  rol: 'usuario'
});

// Crear notificación de rechazo
await db.collection('notificaciones').add({
  userId: userId,
  tipo: 'solicitud_rechazada',
  titulo: 'Solicitud rechazada',
  mensaje: 'Tu solicitud para ser vendedor ha sido rechazada. Motivo: [motivo]',
  leida: false,
  fecha: FieldValue.serverTimestamp()
});
```

---

### 3️⃣ Usuario Recibe Notificación

**Ubicación:** `lib/widgets/usuario/notification_badge.dart`

El widget de notificaciones muestra:
- 🔴 Badge con número de notificaciones sin leer
- Modal con lista de notificaciones
- Al hacer tap en notificación de aprobación:
  - Se marca como leída
  - El usuario se convierte automáticamente en vendedor
  - Puede empezar a subir productos

---

### 4️⃣ Vendedor Sube Productos

**Ubicación:** 
- `lib/screens/comer/subir_producto_screen.dart`
- `lib/screens/comer/pasos_producto_screen.dart`

Todos los productos se guardan con `vendedorId`:

```dart
collection: productos
{
  nombre: "Producto X",
  descripcion: "...",
  precio: 50.00,
  stock: 10,
  categoria: "Dulces",
  subcategoria: "Chocolate",
  fotos: ["url1", "url2"],
  pasos: [...],
  vendedorId: "uid_del_vendedor", // 👈 Identifica al vendedor
  fecha: timestamp
}
```

---

### 5️⃣ Cambio Entre Roles

**Ubicación:** `lib/widgets/usuario/role_switcher.dart`

Los vendedores aprobados pueden cambiar entre:
- 🛒 **Modo Usuario** - Ver productos, comprar
- 🏪 **Modo Vendedor** - Subir productos, gestionar inventario

El widget muestra:
```
[👤 Usuario  🔄]  o  [🏪 Vendedor  🔄]
```

Al hacer tap en 🔄:
- Se actualiza `usuarios/{userId}/rol`
- Se muestra confirmación
- La UI se adapta al nuevo rol

---

## 📁 Estructura de Firestore

```
firestore/
├── solicitudes/
│   └── {solicitudId}
│       ├── userId
│       ├── email
│       ├── nombre
│       ├── descripcion
│       ├── comunidad
│       ├── estado (pendiente | aprobada | rechazada)
│       ├── imagenes[]
│       └── fecha
│
├── usuarios/
│   └── {userId}
│       ├── email
│       ├── rol (usuario | solicitante | vendedor)
│       ├── fechaSolicitud
│       └── ultimoCambioRol
│
├── notificaciones/
│   └── {notificacionId}
│       ├── userId
│       ├── tipo (solicitud_aprobada | solicitud_rechazada)
│       ├── titulo
│       ├── mensaje
│       ├── leida (boolean)
│       └── fecha
│
└── productos/
    └── {productoId}
        ├── nombre
        ├── vendedorId  👈 Clave para filtrar productos por vendedor
        └── ... (otros campos)
```

---

## 🛠️ Servicios Creados

### `VendorService`
**Ubicación:** `lib/services/vendor_service.dart`

Métodos:
- `getRolUsuario()` - Obtiene rol actual (usuario/vendedor)
- `cambiarRol(nuevoRol)` - Cambia entre vendedor/usuario
- `puedeSerVendedor()` - Verifica si tiene solicitud aprobada
- `getNotificaciones()` - Stream de notificaciones sin leer
- `marcarNotificacionLeida(id)` - Marca notificación como leída
- `getMisProductos()` - Stream de productos del vendedor

### `NotificationService`
**Ubicación:** `lib/services/notification_service.dart`

Métodos estáticos:
- `enviarNotificacionAprobacion(userId, nombre)`
- `enviarNotificacionRechazo(userId, motivo)`

---

## 🎨 Widgets Creados

### `NotificationBadge`
**Ubicación:** `lib/widgets/usuario/notification_badge.dart`

- Muestra icono de campana con badge de contador
- Abre modal con lista de notificaciones
- Permite marcar como leídas

### `RoleSwitcher`
**Ubicación:** `lib/widgets/usuario/role_switcher.dart`

- Muestra rol actual (Usuario/Vendedor)
- Botón para alternar entre roles
- Solo visible si el usuario tiene solicitud aprobada

---

## 📱 Integración en la UI

### En el AppBar o Dashboard:

```dart
AppBar(
  actions: [
    const RoleSwitcher(),
    const SizedBox(width: 8),
    const NotificationBadge(),
  ],
)
```

---

## 🔐 Reglas de Seguridad (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Solicitudes
    match /solicitudes/{solicitudId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.token.admin == true; // Solo admin
    }
    
    // Usuarios
    match /usuarios/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || request.auth.token.admin == true;
    }
    
    // Notificaciones
    match /notificaciones/{notifId} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.token.admin == true; // Solo admin crea
    }
    
    // Productos
    match /productos/{productoId} {
      allow read: if true; // Todos pueden ver
      allow create: if request.auth != null && 
                       get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'vendedor';
      allow update, delete: if request.auth.uid == resource.data.vendedorId;
    }
  }
}
```

---

## ✅ Checklist de Implementación

- [x] Servicio de vendedores
- [x] Servicio de notificaciones
- [x] Widget de notificaciones
- [x] Widget de cambio de roles
- [x] Guardar vendedorId en productos
- [x] Actualizar solicitud con userId
- [ ] Agregar widgets a la UI principal
- [ ] Configurar panel de administración
- [ ] Configurar reglas de Firestore
- [ ] Probar flujo completo

---

## 🚀 Próximos Pasos

1. **Agregar widgets a la UI:**
   - Colocar `NotificationBadge` en el AppBar
   - Colocar `RoleSwitcher` en perfil o drawer

2. **Panel de Administración:**
   - Crear vista de solicitudes pendientes
   - Botones de aprobar/rechazar
   - Implementar llamadas a NotificationService

3. **Testing:**
   - Enviar solicitud desde app
   - Aprobar desde panel admin
   - Verificar notificación en app
   - Probar subida de productos
   - Probar cambio de roles

---

## 📞 Soporte

Para dudas o problemas, consulta la documentación de Firebase:
- [Firestore](https://firebase.google.com/docs/firestore)
- [Authentication](https://firebase.google.com/docs/auth)
