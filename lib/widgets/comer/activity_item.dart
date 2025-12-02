import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityItem extends StatelessWidget {
  final String name;
  final String action;
  final String imageUrl;

  const ActivityItem({
    super.key,
    required this.name,
    required this.action,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$name\n$action',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.87 * 255).round(),
                ),
              ),
            ),
          ),
          Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
          ),
        ],
      ),
    );
  }
}
