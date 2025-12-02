import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Precio + estrellas
        Row(
          children: [
            Text(
              "\$$price",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                rating,
                (index) => Icon(
                  Icons.star,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        // Botón de favorito
        IconButton(
          icon: Icon(
            Icons.thumb_up,
            color: isFavorite
                ? theme.colorScheme.secondary
                : theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          ),
          onPressed: onFavoriteToggle,
        ),
      ],
    );
  }
}
