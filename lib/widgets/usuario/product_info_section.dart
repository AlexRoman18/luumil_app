import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductInfoSection extends StatelessWidget {
  final double price;
  final int rating;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ProductInfoSection({
    super.key,
    required this.price,
    required this.rating,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Precio + estrellas
        Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "\$${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                  TextSpan(
                    text: " /Kg",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF007BFF).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                rating,
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
            ),
          ],
        ),

        // Botón de favorito
        IconButton(
          icon: Icon(
            Icons.thumb_up,
            color: isFavorite ? AppColors.primary : Colors.black54,
          ),
          onPressed: onFavoriteToggle,
        ),
      ],
    );
  }
}
