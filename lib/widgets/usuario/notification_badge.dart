import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/services/vendor_service.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final vendorService = VendorService();

    return StreamBuilder<QuerySnapshot>(
      stream: vendorService.getNotificaciones(),
      builder: (context, snapshot) {
        // Siempre mostrar campanita, incluso mientras carga
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () => _mostrarNotificaciones(context, []),
          );
        }

        final notificaciones = snapshot.data!.docs;
        if (notificaciones.isEmpty) {
          return IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () => _mostrarNotificaciones(context, []),
          );
        }

        return Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
              ),
              onPressed: () => _mostrarNotificaciones(context, notificaciones),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${notificaciones.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarNotificaciones(
    BuildContext context,
    List<QueryDocumentSnapshot> notificaciones,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _NotificacionesModal(notificaciones: notificaciones),
    );
  }
}

class _NotificacionesModal extends StatelessWidget {
  final List<QueryDocumentSnapshot> notificaciones;

  const _NotificacionesModal({required this.notificaciones});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notificaciones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          if (notificaciones.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No tienes notificaciones',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: notificaciones.length,
                itemBuilder: (context, index) {
                  final notif = notificaciones[index];
                  final data = notif.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: data['tipo'] == 'solicitud_aprobada'
                            ? Colors.green
                            : Colors.orange,
                        child: Icon(
                          data['tipo'] == 'solicitud_aprobada'
                              ? Icons.check
                              : Icons.info,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        data['titulo'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(data['mensaje'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () async {
                          await VendorService().marcarNotificacionLeida(
                            notif.id,
                          );
                        },
                      ),
                      onTap: () async {
                        // Marcar como leída
                        await VendorService().marcarNotificacionLeida(notif.id);

                        // Si es aprobación, activar modo vendedor
                        if (data['tipo'] == 'solicitud_aprobada') {
                          if (context.mounted) {
                            final vendorService = VendorService();
                            await vendorService.cambiarRol('vendedor');

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '¡Bienvenido! Ahora eres vendedor. Puedes subir productos.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
