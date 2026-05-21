import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:luumil_app/services/cache_service.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta moderna y minimalista reutilizable
class ModernCard extends StatelessWidget {
  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation = CardElevation.low,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final CardElevation elevation;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: _getShadow(),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: card,
      );
    }

    return card;
  }

  List<BoxShadow> _getShadow() {
    switch (elevation) {
      case CardElevation.none:
        return [];
      case CardElevation.low:
        return AppColors.cardShadow;
      case CardElevation.medium:
        return AppColors.elevatedShadow;
    }
  }
}

enum CardElevation { none, low, medium }

/// Tarjeta de producto moderna
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.subtitle,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final double price;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                cacheManager: CacheService.cacheManager,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.textBase,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: AppTypography.textSm,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: AppSpacing.sm),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: AppTypography.textLg,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      TextSpan(
                        text: '',
                        style: GoogleFonts.poppins(
                          fontSize: AppTypography.textSm,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF007BFF).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
