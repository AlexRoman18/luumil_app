import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HorarioRow extends StatelessWidget {
  final String dia;
  final String hora;

  const HorarioRow({super.key, required this.dia, required this.hora});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
          children: [
            TextSpan(
              text: "$dia: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: hora),
          ],
        ),
      ),
    );
  }
}
