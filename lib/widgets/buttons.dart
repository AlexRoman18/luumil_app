import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
    required this.color,
    required this.text,
    this.onPressed,
    required this.colorText,
  });

  final Color color;
  final String text;
  final VoidCallback? onPressed;
  final Color colorText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 55), // 👈 ancho ocupa todo, alto 55
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 5,
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: colorText),
      ),
    );
  }
}
