import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/widgets/buttons.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Transform.translate(
      offset: const Offset(0, -60),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withAlpha(
                (0.08 * 255).round(),
              ),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.surface,
              child: Icon(
                Icons.person_outline,
                size: 50,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tienda",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat(context, "2M", "Seguidores"),
                _divider(context),
                _buildStat(context, "120", "Me gusta"),
                _divider(context),
                _buildStat(context, "20", "Productos"),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.85 * 255).round(),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Buttons(text: "Seguir", onPressed: () {}),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Buttons(
                    color: theme.colorScheme.surface,
                    text: "Mensaje",
                    colorText: theme.colorScheme.primary,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withAlpha(
                          (0.08 * 255).round(),
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.thumb_up_alt_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String number, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withAlpha((0.85 * 255).round()),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 25,
      width: 1,
      color: theme.colorScheme.onSurface.withAlpha((0.12 * 255).round()),
    );
  }
}
