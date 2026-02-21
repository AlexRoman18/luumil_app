import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePostCard extends StatelessWidget {
  const ProfilePostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> productos = [
      {'nombre': 'Venta de tomate', 'precio': 12},
      {'nombre': 'Venta de limones', 'precio': 18},
      {'nombre': 'Venta de naranja', 'precio': 10},
    ];

    return Column(
      children: productos.map((producto) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF007BFF),
              child: Icon(Icons.shopping_bag, color: Colors.white),
            ),
            title: Text(
              producto['nombre'] as String,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '\$${producto['precio']}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' /Kg',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF007BFF).withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.more_vert),
          ),
        );
      }).toList(),
    );
  }
}
