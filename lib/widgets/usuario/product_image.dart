import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';

class ProductImage extends StatelessWidget {
  final Image image;
  const ProductImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
        image: DecorationImage(image: image.image, fit: BoxFit.cover),
      ),
    );
  }
}
