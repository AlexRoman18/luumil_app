import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/config/theme/app_colors.dart';

/// Bot\u00f3n moderno y minimalista con variantes
class ModernButton extends StatelessWidget {
  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.fullWidth = true,
    this.loading = false,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool fullWidth;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          disabledBackgroundColor: AppColors.divider,
          disabledForegroundColor: AppColors.textHint,
          elevation: variant == ButtonVariant.primary ? 0 : 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: variant == ButtonVariant.outlined
                ? BorderSide(color: AppColors.primary, width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(_getForegroundColor()),
                ),
              )
            : Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: AppTypography.textBase,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.surface;
      case ButtonVariant.outlined:
        return Colors.transparent;
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return AppColors.textPrimary;
      case ButtonVariant.outlined:
        return AppColors.primary;
      case ButtonVariant.text:
        return AppColors.primary;
    }
  }
}

enum ButtonVariant { primary, secondary, outlined, text }

// Mantener compatibilidad con código existente
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: colorText,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: AppTypography.textBase,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
