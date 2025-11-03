import 'package:flutter/material.dart';
import '../widgets/product_image.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_description.dart';

class Categoria2 extends StatefulWidget {
  final String title;
  final String image;
  final double price;
  final String description;

  const Categoria2({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.description,
  });

  @override
  State<Categoria2> createState() => _Categoria2State();
}

class _Categoria2State extends State<Categoria2> {
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
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              ProductImage(image: Image.asset(widget.image)),
              const SizedBox(height: 8),

              ProductInfoSection(
                price: widget.price,
                rating: 5,
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              ),
              const SizedBox(height: 16),

              ProductDescription(
                title: widget.title,
                description: widget.description,
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
