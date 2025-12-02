import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
    this.color,
    required this.text,
    this.onPressed,
    this.colorText,
    this.height,
  });

  final Color? color;
  final String text;
  final VoidCallback? onPressed;
  final Color? colorText;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = color ?? theme.colorScheme.primary;
    final foreground = colorText ?? theme.colorScheme.onPrimary;
    final h = height ?? 48.0;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        minimumSize: Size(double.infinity, h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        elevation: 5,
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(text, style: TextStyle(color: foreground)),
    );
  }
}
