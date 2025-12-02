import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        StatCard(
          label: 'Valoraciones de la tienda',
          value: '4.8',
          icon: Icons.star,
          color: theme.colorScheme.primaryContainer,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Likes de la tienda',
                value: '100',
                icon: Icons.favorite,
                color: theme.colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatCard(
                label: 'Likes totales de tus publicaciones',
                value: '780',
                icon: Icons.favorite,
                color: theme.colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
