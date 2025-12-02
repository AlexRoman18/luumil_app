import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
    this.color,
    required this.text,
    this.onPressed,
    this.colorText,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.height,
  });

  final Color? color;
  final String text;
  final VoidCallback? onPressed;
  final Color? colorText;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = color ?? theme.colorScheme.primary;
    final foreground = colorText ?? theme.colorScheme.onPrimary;
    final side = BorderSide(
      color: borderColor ?? Colors.transparent,
      width: borderWidth ?? 0,
    );
    final radius = borderRadius ?? 50.0;
    final h = height ?? 48.0;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        minimumSize: Size(double.infinity, h),
        elevation: 5,
        side: side,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(text, style: TextStyle(color: foreground)),
    );
  }
}
