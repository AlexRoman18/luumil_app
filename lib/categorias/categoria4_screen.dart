import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/screens/perfil_screen.dart';

class Categoria4Screen extends StatelessWidget {
  const Categoria4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "title": "Pan dulce tradicional",
        "desc": "Pan artesanal horneado con receta familiar y azúcar morena",
        "price": 12.0,
        "stock": 80,
        "image": "assets/images/pan_dulce.png",
      },
      {
        "title": "Galletas de miel melipona",
        "desc": "Galletas suaves hechas con miel natural de abejas meliponas",
        "price": 30.0,
        "stock": 40,
        "image": "assets/images/galletas_miel.png",
      },
      {
        "title": "Pastel de yuca",
        "desc": "Repostería típica elaborada con yuca rallada y coco",
        "price": 55.0,
        "stock": 25,
        "image": "assets/images/pastel_yuca.png",
      },
      {
        "title": "Pan de elote",
        "desc": "Pan casero con granos de elote fresco, dulce y esponjoso",
        "price": 40.0,
        "stock": 30,
        "image": "assets/images/pan_elote.png",
      },
      {
        "title": "Empanadas de coco",
        "desc": "Empanadas rellenas de coco rallado y miel artesanal",
        "price": 35.0,
        "stock": 28,
        "image": "assets/images/empanadas_coco.png",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Buscar...", style: TextStyle(color: Colors.black54)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return _ProductCard(
            title: p["title"] as String,
            description: p["desc"] as String,
            price: p["price"] as double,
            stock: p["stock"] as int,
            image: p["image"] as String,
            onViewMore: () {},
            onGoToShop: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final int stock;
  final String image;
  final VoidCallback onViewMore;
  final VoidCallback onGoToShop;

  const _ProductCard({
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    required this.onViewMore,
    required this.onGoToShop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // ✅ Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ✅ Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                  const SizedBox(height: 4),
                  Text("Costo: \$${price.toStringAsFixed(2)} c/u"),
                  Text("Disponible: $stock piezas"),
                  const SizedBox(height: 6),

                  // ✅ Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onViewMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Ver más"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onGoToShop,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Tienda",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
