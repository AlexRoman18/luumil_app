import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final String? fotoPerfil;
  final String nombre;
  final String descripcion;
  final VoidCallback? onEditFoto;
  final VoidCallback? onEditNombre;
  final VoidCallback? onEditDescripcion;

  const ProfileHeader({
    super.key,
    this.fotoPerfil,
    required this.nombre,
    required this.descripcion,
    this.onEditFoto,
    this.onEditNombre,
    this.onEditDescripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -60),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: onEditFoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: fotoPerfil != null
                        ? NetworkImage(fotoPerfil!)
                        : const AssetImage('assets/icons/tienda.png')
                              as ImageProvider,
                  ),
                  if (onEditFoto != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onEditNombre != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEditNombre,
                    child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  ),
                ],
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    descripcion,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (onEditDescripcion != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEditDescripcion,
                    child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
