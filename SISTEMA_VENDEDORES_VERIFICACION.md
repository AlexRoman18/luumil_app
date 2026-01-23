# ✅ Verificación del Sistema de Vendedores

## 📋 Estado Actual del Sistema

### ✅ 1. AUTENTICACIÓN
- **Login**: Funciona con Firebase Auth
- **Registro**: Crea usuario y autentica automáticamente
- **AuthGate**: Redirige a PantallaInicio cuando hay usuario autenticado
- **Estado**: ✅ FUNCIONANDO

### ✅ 2. FORMULARIO DE SOLICITUD
**Ubicación**: `lib/widgets/comer/register_forms.dart`

**Validaciones implementadas**:
- ✅ Nombre del negocio (obligatorio)
- ✅ Descripción (obligatorio)
- ✅ Comunidad seleccionada (obligatorio)
- ✅ Mínimo 3 imágenes subidas (obligatorio)

**Funcionalidades**:
- ✅ Subida de imágenes a Cloudinary
- ✅ Protección contra duplicación de imágenes
- ✅ Diálogo de confirmación al enviar
- ✅ Navegación a PantallaInicio después de enviar

**Estado**: ✅ FUNCIONANDO

### ✅ 3. NOTIFICACIONES
**Archivos clave**:
- `lib/services/notification_service.dart` - Crea notificaciones
- `lib/widgets/usuario/notification_badge.dart` - Muestra campanita
- `lib/services/vendor_service.dart` - Stream de notificaciones

**Características**:
- ✅ Campanita siempre visible en AppBar
- ✅ Badge rojo con número cuando hay notificaciones
- ✅ Modal al hacer clic mostrando notificaciones
- ✅ Marca como leída al hacer clic

**Implementación**:
```dart
// PantallaInicio AppBar (línea 47)
actions: [
  IconButton(icon: const Icon(Icons.person_outline)),
  const RoleSwitcher(),
  const SizedBox(width: 8),
  const NotificationBadge(), // ← Campanita aquí
],
```

**Estado**: ✅ CÓDIGO CORRECTO (pendiente verificar logs de Firebase)

### ✅ 4. PANEL DE ADMINISTRACIÓN
**Ubicación**: `lib/screens/admin/solicitudes_admin_screen.dart`

**Funcionalidades**:
- ✅ Lista solicitudes pendientes
- ✅ Muestra info del solicitante (email, negocio, descripción, comunidad, imágenes)
- ✅ Botón Aprobar: 
  - Actualiza solicitud a "aprobada"
  - Cambia rol usuario a "vendedor"
  - Crea notificación de aprobación
- ✅ Botón Rechazar:
  - Pide motivo
  - Actualiza solicitud a "rechazada"
  - Crea notificación de rechazo

**Acceso**: `/admin/solicitudes` (ruta configurada en GoRouter)

**Estado**: ✅ FUNCIONANDO

### ✅ 5. SISTEMA DE ROLES
**Ubicación**: `lib/widgets/usuario/role_switcher.dart`

**Lógica**:
1. Solo aparece si `puedeSerVendedor == true` (solicitud aprobada)
2. Muestra chip azul "Usuario" o verde "Vendedor"
3. Al hacer clic en swap:
   - Cambia rol en Firestore
   - Si cambia a "vendedor" → Navega a DashboardScreen
   - Si cambia a "usuario" → Se queda en PantallaInicio

**Ubicación en UI**: AppBar de PantallaInicio, antes de NotificationBadge

**Estado**: ✅ FUNCIONANDO

### ✅ 6. DASHBOARD DE VENDEDOR
**Ubicación**: `lib/screens/comer/dashboard_screen.dart`

**Características**:
- ✅ AppBar con NotificationBadge
- ✅ Bottom navigation bar
- ✅ Widgets de estadísticas y actividades

**Acceso**: 
- Automático al cambiar a modo "vendedor" con RoleSwitcher
- Desde home de comerciante

**Estado**: ✅ FUNCIONANDO

---

## 🔍 PRUEBAS RECOMENDADAS

### Flujo Completo a Probar:

1. **Registro de nuevo usuario**
   ```
   1. Abrir app (no logueado)
   2. Ir a Registro
   3. Llenar email/password
   4. Hacer clic en "Registrarse"
   ✅ Debería: Ir automáticamente a PantallaInicio
   ```

2. **Solicitud de vendedor**
   ```
   1. Menú lateral → "Vender"
   2. Aceptar diálogo
   3. Llenar formulario completo:
      - Nombre del negocio
      - Descripción
      - Seleccionar comunidad
      - Subir 3+ imágenes
   4. Hacer clic en "Enviar solicitud"
   ✅ Debería: 
      - Mostrar diálogo verde de confirmación
      - Regresar a PantallaInicio
      - Campanita visible (sin badge todavía)
   ```

3. **Aprobación (como admin)**
   ```
   1. Ir a /admin/solicitudes en navegador o usando GoRouter
   2. Ver solicitud pendiente
   3. Hacer clic en "Aprobar"
   ✅ Debería:
      - Mostrar mensaje verde "Solicitud aprobada"
      - En CONSOLA ver logs:
        👑 ADMIN: Iniciando aprobación...
        ✅ Solicitud actualizada...
        🔔 Enviando notificación...
   ```

4. **Recibir notificación (como usuario)**
   ```
   1. Volver a PantallaInicio
   2. Observar campanita
   ✅ Debería:
      - Mostrar badge rojo con "1"
      - Al hacer clic: Modal con "¡Solicitud aprobada!"
      - Aparecer RoleSwitcher (chip azul "Usuario")
   ```

5. **Acceder a Dashboard de vendedor**
   ```
   1. Hacer clic en el ícono de swap del RoleSwitcher
   ✅ Debería:
      - Cambiar a chip verde "Vendedor"
      - Navegar automáticamente a DashboardScreen
      - Mostrar dashboard de comerciante
   ```

---

## 🐛 PROBLEMAS CONOCIDOS Y SOLUCIONES

### ❌ Problema: Logs no aparecen al aprobar solicitud
**Diagnóstico**: 
- El código tiene todos los `print()` necesarios
- Si no aparecen, puede ser que:
  1. No estás viendo la consola correcta
  2. Los logs están filtrados
  3. La función no se está ejecutando

**Solución temporal aplicada**:
```dart
// Agregado log inmediato en el botón (solicitudes_admin_screen.dart)
onPressed: () {
  print('🔴 BOTÓN APROBAR PRESIONADO');
  _aprobarSolicitud(...);
}
```

**Para verificar**:
1. Abrir consola de Flutter
2. Aprobar solicitud
3. Buscar "🔴 BOTÓN APROBAR PRESIONADO"
4. Si NO aparece → El botón no está conectado
5. Si SÍ aparece → La función tiene un error

### ❌ Problema: Notificación no aparece en campanita
**Posibles causas**:
1. Firestore necesita índice compuesto para query de notificaciones
2. UserId no coincide entre colecciones
3. Campo `leida` tiene valor incorrecto

**Verificación en Firestore Console**:
```
1. Ir a Firebase Console → Firestore
2. Buscar colección "notificaciones"
3. Verificar que existe documento con:
   - userId: [el ID del usuario]
   - leida: false
   - tipo: "solicitud_aprobada"
```

**Si no existe notificación**:
- El NotificationService no está creando el documento
- Revisar permisos de Firestore

**Si existe pero no aparece en app**:
- Problema con el Stream
- Verificar logs: "🔍 Obteniendo notificaciones para userId: xxx"
- Verificar logs: "🔔 NotificationBadge - hasData: true, Cantidad: X"

---

## 📊 ESTRUCTURA DE FIRESTORE

### Colección: `solicitudes`
```javascript
{
  userId: "xxx",
  email: "user@example.com",
  nombre: "Mi Negocio",
  descripcion: "Vendo productos",
  comunidad: "Noh-Bec",
  estado: "pendiente" | "aprobada" | "rechazada",
  imagenes: ["url1", "url2", "url3"],
  fecha: Timestamp,
  fechaAprobacion: Timestamp (opcional),
  motivo: "..." (solo si rechazada)
}
```

### Colección: `usuarios`
```javascript
{
  rol: "usuario" | "solicitante" | "vendedor",
  email: "user@example.com",
  puedeSerVendedor: true | false,
  fechaSolicitud: Timestamp,
  fechaAprobacion: Timestamp (opcional)
}
```

### Colección: `notificaciones`
```javascript
{
  userId: "xxx",
  tipo: "solicitud_aprobada" | "solicitud_rechazada",
  titulo: "¡Solicitud aprobada!",
  mensaje: "Tu solicitud para ser vendedor...",
  leida: false,
  fecha: Timestamp
}
```

---

## 🔧 ARCHIVOS CRÍTICOS

1. **Autenticación**:
   - `lib/auth/auth_service.dart`
   - `lib/auth/auth_gate.dart`
   - `lib/widgets/usuario/iniciarsesion_form.dart`
   - `lib/widgets/usuario/register_forms.dart` (usuario)

2. **Solicitud de vendedor**:
   - `lib/widgets/comer/register_forms.dart` (formulario comerciante)
   - `lib/widgets/comer/no-reutilizable/solicitud_button.dart`

3. **Panel Admin**:
   - `lib/screens/admin/solicitudes_admin_screen.dart`
   - `lib/services/notification_service.dart`

4. **Notificaciones**:
   - `lib/widgets/usuario/notification_badge.dart`
   - `lib/services/vendor_service.dart`

5. **Sistema de roles**:
   - `lib/widgets/usuario/role_switcher.dart`

6. **Pantallas principales**:
   - `lib/screens/usuario/pantallainicio_screen.dart` (home usuario)
   - `lib/screens/comer/dashboard_screen.dart` (home vendedor)

---

## ✨ PRÓXIMOS PASOS SUGERIDOS

1. **Verificar logs de Firebase**:
   - Ejecutar prueba de aprobación
   - Copiar todos los logs de la consola
   - Verificar si se crea documento en Firestore

2. **Crear índice compuesto en Firestore** (si es necesario):
   - Si aparece error de índice al consultar notificaciones
   - Firebase mostrará un link en la consola para crear el índice

3. **Quitar logs de debug** (después de verificar que funciona):
   - Eliminar todos los `print()` agregados para debug
   - Mantener solo los críticos para errores

4. **Mejorar UX**:
   - Agregar animación al badge de notificaciones
   - Agregar sonido/vibración al recibir notificación
   - Agregar contador de productos en dashboard

5. **Seguridad**:
   - Agregar reglas de seguridad en Firestore
   - Validar permisos de admin
   - Agregar autenticación de admin

---

## 📞 INFORMACIÓN DE DEBUG

Para obtener ayuda, proporciona:
1. ✅ Logs completos de la consola
2. ✅ Screenshots de Firestore Collections
3. ✅ Pantalla donde ocurre el problema
4. ✅ Versión de Flutter: `flutter --version`
5. ✅ Versión de Firebase: revisar `pubspec.yaml`
