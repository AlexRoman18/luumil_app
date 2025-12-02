import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? content;
  final Widget? contentWidget;

  const ProfileSection({
    super.key,
    required this.title,
    required this.icon,
    this.content,
    this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 18,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.7 * 255).round(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (content != null)
            Text(
              content!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.9 * 255).round(),
                ),
              ),
            ),
          if (contentWidget != null) contentWidget!,
        ],
      ),
    );
  }
}
