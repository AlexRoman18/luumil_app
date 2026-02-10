# Sistema de Mensajería y Referencias de Pago - Luumil App

## 📋 Descripción General

Se ha implementado un sistema completo de mensajería entre usuarios y vendedores con capacidad de envío de referencias de pago. El vendedor puede enviar referencias de pago a través del chat, y los usuarios pueden verlas y procesarlas desde el ícono de etiqueta (label) en la pantalla principal.

---

## 🏗️ Estructura de Firestore

### Colección: `chats`
```
chats/
  {chatId}/  (formato: usuarioId_vendedorId, IDs ordenados alfabéticamente)
    - participantes: [usuarioId, vendedorId]
    - ultimoMensaje: string
    - ultimoTimestamp: timestamp
    - vendedorId: string
    - usuarioId: string
    
    mensajes/
      {mensajeId}/
        - tipo: "texto" | "referencia_pago"
        - senderId: string
        - timestamp: timestamp
        - leido: boolean
        
        // Campos para tipo "texto"
        - texto: string
        
        // Campos para tipo "referencia_pago"
        - referenciaId: string
        - monto: double
        - concepto: string
```

### Colección: `referencias_pago`
```
referencias_pago/
  {referenciaId}/
    - vendedorId: string
    - usuarioId: string
    - chatId: string
    - monto: double
    - concepto: string
    - estado: "pendiente" | "pagado"
    - timestamp: timestamp
    
    // Campos adicionales cuando estado = "pagado"
    - metodoPago: "paypal" | "mercadopago" | "tarjeta"
    - fechaPago: timestamp
```

---

## 📱 Pantallas Implementadas

### 1. **MensajesVendedorScreen** (Vendedor)
📍 `lib/screens/comer/mensajes_vendedor_screen.dart`

**Funcionalidad:**
- Lista de todas las conversaciones del vendedor
- Ordenadas por último mensaje (más reciente primero)
- Muestra foto de perfil, nombre del usuario y preview del último mensaje
- Al tocar una conversación, abre el chat con `esVendedor: true`

**Características:**
- StreamBuilder para actualizaciones en tiempo real
- Formato de fecha inteligente (hoy, ayer, días, fecha completa)
- Estado vacío cuando no hay mensajes
- Card design con elevación y bordes sutiles

---

### 2. **ChatScreen** (Compartida Usuario/Vendedor)
📍 `lib/screens/usuario/chat_screen.dart`

**Parámetros:**
```dart
ChatScreen({
  required String vendedorId,
  required String vendedorNombre,
  bool esVendedor = false,
})
```

**Funcionalidad:**
- Chat en tiempo real con Firebase Firestore
- Mensajes de texto estándar
- Mensajes de tipo "referencia_pago" con diseño especial
- Botón de envío de referencias de pago (solo visible para vendedores)

**Características Especiales:**

#### Para Vendedores (`esVendedor = true`):
- Botón **💰** (attach_money) visible en el input
- Al presionar, abre diálogo para:
  - Ingresar monto (MXN)
  - Ingresar concepto/descripción
- Crea documento en `referencias_pago`
- Envía mensaje especial en el chat

#### Diseño de Mensajes:
**Texto normal:**
- Color azul para mensajes propios
- Color blanco para mensajes recibidos
- Timestamp formateado

**Referencias de pago:**
- Color verde para mensajes propios del vendedor
- Color verde claro para referencias recibidas
- Muestra ícono de recibo 💳
- Monto destacado en grande
- Concepto debajo
- Timestamp

---

### 3. **ReferenciasPagoScreen** (Usuario)
📍 `lib/screens/usuario/referencias_pago_screen.dart`

**Funcionalidad:**
- Lista todas las referencias de pago del usuario
- Separadas por estado: "pendiente" y "pagado"
- Información del vendedor con foto de perfil
- Botón "Pagar" para referencias pendientes

**Proceso de Pago:**

1. Usuario toca botón "Pagar"
2. BottomSheet con 3 opciones:
   - 💳 **PayPal** (azul)
   - 💰 **Mercado Pago** (azul claro)
   - 💳 **Tarjeta** (gris)

3. Al seleccionar método:
   - Muestra diálogo de carga "Procesando pago..."
   - Actualiza Firestore:
     ```dart
     estado: "pagado"
     metodoPago: "paypal" | "mercadopago" | "tarjeta"
     fechaPago: serverTimestamp()
     ```
   - Muestra confirmación ✅ "¡Pago exitoso!"

**⚠️ NOTA:** Actualmente el pago es simulado. Para producción, necesitas:
- Integrar SDK de Mercado Pago ([docs](https://www.mercadopago.com.mx/developers/es/docs))
- Integrar PayPal SDK ([docs](https://developer.paypal.com/))
- Implementar procesamiento seguro de tarjetas

**Características:**
- StreamBuilder para actualizaciones automáticas
- Cards con borde coloreado según estado
- Avatar del vendedor
- Formato de fecha y hora
- Badge de estado (Pendiente/Pagado)

---

## 🔌 Puntos de Integración

### 1. **Menú del Vendedor**
📍 `lib/widgets/comer/side_menu.dart`

**Actualización:**
- Removido: "Tutorial", "Selección de búsqueda", "Carrito de compra"
- Agregado: **"Mensajes"** (primer ítem)
- Navegación directa a `MensajesVendedorScreen`
- Otros ítems: "Subir Producto", "Mis Productos", "Estadísticas"

### 2. **Pantalla Principal del Usuario**
📍 `lib/screens/usuario/pantallainicio_screen.dart`

**Actualización:**
- Ícono de label (🏷️) conectado
- Al presionar → navega a `ReferenciasPagoScreen`
- Import agregado

### 3. **Perfil del Vendedor**
📍 `lib/screens/usuario/tienda_perfil_screen.dart`

**Botón "Contactar":**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChatScreen(
      vendedorId: widget.vendedorId,
      vendedorNombre: nombreVendedor,
      esVendedor: false,  // Usuario normal
    ),
  ),
);
```

---

## 🎨 Diseño y UX

### Colores:
- **Azul primario:** `#007BFF` (mensajes propios, botones)
- **Verde pago:** `#28A745` (referencias de pago, confirmaciones)
- **Amarillo warning:** `#FFC107` (estado pendiente)
- **Gris background:** `Colors.grey[100]`
- **Blanco:** Cards y mensajes recibidos

### Tipografía:
- **Google Fonts:** Poppins
- **Títulos:** w600, 18-20px
- **Texto normal:** w400, 14px
- **Timestamps:** w400, 10-12px

### Animaciones:
- Scroll automático al enviar mensaje
- Transiciones suaves en navegación
- Diálogos con material design

---

## 🚀 Flujo de Usuario Completo

### Usuario quiere comprar:

1. **Navega productos** → Pantalla Inicio
2. **Entra a perfil del vendedor** → Botón "Contactar"
3. **Abre chat** → Envía mensaje
4. **Vendedor responde** y envía **referencia de pago**
5. **Usuario ve ícono 🏷️** en pantalla principal
6. **Toca ícono** → Ve lista de referencias pendientes
7. **Toca "Pagar"** → Elige método de pago
8. **Confirma pago** → Estado cambia a "Pagado"

### Vendedor gestiona ventas:

1. **Abre menú lateral** → Toca "Mensajes"
2. **Ve lista de chats** ordenados por actividad
3. **Abre conversación** con cliente
4. **Toca botón 💰** → Ingresa monto y concepto
5. **Envía referencia** → Aparece en chat como mensaje especial
6. **Cliente paga** → Vendedor puede verificar en Firestore

---

## 📦 Dependencias Utilizadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_auth: ^latest
  cloud_firestore: ^latest
  
  # UI
  google_fonts: ^latest
  
  # Navegación
  go_router: ^latest
```

---

## ⚙️ Configuración Requerida

### Firestore Rules (Seguridad):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Chats
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participantes;
      
      match /mensajes/{messageId} {
        allow read, write: if request.auth != null &&
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participantes;
      }
    }
    
    // Referencias de pago
    match /referencias_pago/{referenciaId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.vendedorId || 
         request.auth.uid == resource.data.usuarioId);
      
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.vendedorId;
      
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.usuarioId &&
        request.resource.data.estado == 'pagado';
    }
  }
}
```

### Firestore Indexes:

```javascript
// Chats por vendedor
Colección: chats
Campos: vendedorId (Ascending), ultimoTimestamp (Descending)

// Referencias de pago por usuario
Colección: referencias_pago
Campos: usuarioId (Ascending), timestamp (Descending)

// Mensajes por timestamp
Colección: chats/{chatId}/mensajes
Campos: timestamp (Descending)
```

---

## 🔐 Seguridad Implementada

✅ **Autenticación requerida** para todas las operaciones
✅ **Validación de participantes** en chats
✅ **Solo vendedores** pueden crear referencias de pago
✅ **Solo usuarios** pueden actualizar estado a "pagado"
✅ **Query restringido** por userId/vendedorId

---

## 🎯 Próximos Pasos (Pendientes)

### 1. Integración de Pagos Real

#### Mercado Pago (Recomendado para México):
```yaml
dependencies:
  mercado_pago_mobile_checkout: ^version
```

Pasos:
1. Crear cuenta en [Mercado Pago Developers](https://www.mercadopago.com.mx/developers)
2. Obtener `Public Key` y `Access Token`
3. Implementar `_procesarPago()` con SDK real
4. Manejar callbacks de éxito/error
5. Implementar webhooks para confirmaciones

#### PayPal:
```yaml
dependencies:
  flutter_paypal: ^version
```

### 2. Notificaciones Push

Cuando vendedor envía referencia:
```dart
// Enviar notificación al usuario
await sendPushNotification(
  userId: usuarioId,
  title: 'Nueva referencia de pago',
  body: 'Tienes un pago pendiente de \$$monto',
);
```

### 3. Historial de Pagos

Pantalla adicional para ver todos los pagos completados con:
- Filtros por fecha
- Búsqueda por vendedor
- Descargar recibo en PDF

### 4. Chat Mejorado

- Indicador de "escribiendo..."
- Confirmación de lectura (doble check)
- Envío de imágenes
- Mensajes de voz

---

## 🐛 Debugging

### Ver datos en Firestore Console:

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar proyecto
3. Firestore Database
4. Ver colecciones: `chats`, `referencias_pago`

### Logs útiles:

```dart
// En chat_screen.dart para debug
print('Chat ID: ${_getChatId()}');
print('Mensaje enviado: $mensaje');
print('Usuario: $_userId, Vendedor: ${widget.vendedorId}');

// En referencias_pago_screen.dart
print('Referencias encontradas: ${referencias.length}');
print('Estado: ${referencia['estado']}');
```

---

## 📞 Soporte

Para dudas sobre implementación:
- Firebase: https://firebase.google.com/docs
- Flutter: https://docs.flutter.dev
- Mercado Pago: https://www.mercadopago.com.mx/developers/es/docs

---

**✨ Sistema completamente funcional implementado con éxito!**

Todas las pantallas creadas, navegación conectada, y estructura de Firestore diseñada. Solo falta la integración real de pasarelas de pago para producción.
