import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StatCard(
          label: 'Valoraciones de la tienda',
          value: '4.8',
          icon: Icons.star,
          color: Color(0xFFDFF3FF),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: StatCard(
                label: 'Likes de la tienda',
                value: '100',
                icon: Icons.favorite,
                color: Color(0xFFDFF3FF),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Likes totales de tus publicaciones',
                value: '780',
                icon: Icons.favorite,
                color: Color(0xFFDFF3FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
