import 'package:flutter/material.dart';
import '../widgets/product_image.dart';
import '../widgets/product_info_section.dart';
import '../widgets/color_selector.dart';
import '../widgets/product_description.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar simulada
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Velas aromáticas",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // para balancear visualmente
                ],
              ),

              const ProductImage(),
              const SizedBox(height: 8),

              ProductInfoSection(
                price: 60,
                rating: 5,
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              ),
              const SizedBox(height: 16),

              const ColorSelector(
                colors: [Colors.amber, Colors.purple, Colors.greenAccent, Colors.teal],
              ),
              const SizedBox(height: 16),

              const ProductDescription(
                title: "Velas aromáticas con cera de abeja",
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam...",
              ),
              const SizedBox(height: 12),
              const ProductDescription(
                title: "",
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
