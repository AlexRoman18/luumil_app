import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/widgets/usuario/buttons.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(
        0,
        -60,
        0,
      ), // sube sobre el fondo azul
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
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_outline, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(
            "Tienda",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat("2M", "Seguidores"),
              _divider(),
              _buildStat("120", "Me gusta"),
              _divider(),
              _buildStat("20", "Productos"),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Buttons(
                  color: Colors.blue,
                  text: "Seguir",
                  colorText: Colors.white,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Buttons(
                  color: Colors.white,
                  text: "Mensaje",
                  colorText: Colors.blue,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  static Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 25,
      width: 1,
      color: Colors.grey[400],
    );
  }
}
