import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grayBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26),
        image: const DecorationImage(
          image: AssetImage('assets/images/vela.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
