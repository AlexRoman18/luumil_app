import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/services/vendedor_service.dart';
import 'package:luumil_app/screens/comer/actividad_detalle_screen.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) {
      return 'Hace un momento';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} d';
    } else {
      return 'Hace ${(diferencia.inDays / 7).floor()} sem';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendedorService = VendedorService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: vendedorService.obtenerActividadReciente(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actividad reciente',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No hay actividad reciente',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final actividades = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividad reciente',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${actividades.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...actividades.map((actividad) {
              final tipo = actividad['tipo'];
              final userName = actividad['userName'] ?? 'Usuario';
              final userFoto = actividad['userFoto'] ?? '';
              final fecha = actividad['fecha'];
              final fechaTexto = fecha != null
                  ? _formatearFecha(fecha.toDate())
                  : '';

              Widget trailing = const SizedBox.shrink();
              String accion = '';

              if (tipo == 'seguidor') {
                accion = 'Empezó a seguirte';
                trailing = const Icon(
                  Icons.person_add,
                  color: Colors.blue,
                  size: 20,
                );
              } else if (tipo == 'like') {
                final productoNombre =
                    actividad['productoNombre'] ?? 'producto';
                accion = 'Le dio me gusta a "$productoNombre"';
                trailing = const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                );
              } else if (tipo == 'resena') {
                final estrellas = actividad['estrellas'] ?? 0;
                final productoNombre =
                    actividad['productoNombre'] ?? 'producto';
                accion = 'Valoró "$productoNombre"';
                trailing = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      estrellas.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ActividadDetalleScreen(actividad: actividad),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: tipo == 'seguidor'
                          ? Colors.blue[100]!
                          : tipo == 'resena'
                          ? Colors.amber[100]!
                          : tipo == 'like'
                          ? Colors.red[100]!
                          : Colors.grey[100]!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: tipo == 'seguidor'
                                ? [Colors.blue[400]!, Colors.blue[600]!]
                                : tipo == 'resena'
                                ? [Colors.amber[400]!, Colors.orange[600]!]
                                : tipo == 'like'
                                ? [Colors.red[400]!, Colors.pink[600]!]
                                : [Colors.grey[400]!, Colors.grey[600]!],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (tipo == 'seguidor'
                                          ? Colors.blue
                                          : tipo == 'resena'
                                          ? Colors.amber
                                          : tipo == 'like'
                                          ? Colors.red
                                          : Colors.grey)
                                      .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            tipo == 'seguidor'
                                ? Icons.person_add_rounded
                                : tipo == 'like'
                                ? Icons.favorite_rounded
                                : Icons.star_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              accion,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (fechaTexto.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    fechaTexto,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[300],
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
