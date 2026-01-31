import 'package:flutter/material.dart';
import 'package:luumil_app/services/vendedor_service.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vendedorService = VendedorService();

    return FutureBuilder<Map<String, dynamic>>(
      future: vendedorService.obtenerEstadisticasVendedor(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final stats =
            snapshot.data ??
            {
              'totalLikes': 0,
              'promedioEstrellas': 0.0,
              'seguidores': 0,
              'totalResenas': 0,
            };

        final promedioEstrellas = (stats['promedioEstrellas'] as double)
            .toStringAsFixed(1);
        final seguidores = stats['seguidores'].toString();
        final totalLikes = stats['totalLikes'].toString();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Seguidores',
                    value: seguidores,
                    icon: Icons.people,
                    color: const Color(0xFFDFF3FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    label: 'Likes totales',
                    value: totalLikes,
                    icon: Icons.favorite,
                    color: const Color(0xFFDFF3FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StatCard(
              label: 'Valoración promedio',
              value: promedioEstrellas,
              icon: Icons.star,
              color: const Color(0xFFDFF3FF),
            ),
          ],
        );
      },
    );
  }
}
