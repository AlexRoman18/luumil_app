import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final Image image;
  const ProductImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha((0.98 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withAlpha((0.12 * 255).round()),
        ),
        image: DecorationImage(image: image.image, fit: BoxFit.cover),
      ),
    );
  }
}
