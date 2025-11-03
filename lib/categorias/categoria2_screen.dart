import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/screens/perfil_screen.dart';
import 'package:luumil_app/verMas_categories/categoria2.dart';

class Categoria2Screen extends StatelessWidget {
  const Categoria2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "title": "Piña miel",
        "desc":
            "Piña cultivada en huertos locales, jugosa y naturalmente dulce.",
        "price": 25.0,
        "stock": 50,
        "image": "assets/images/pina-miel.png",
      },
      {
        "title": "Papaya maradol",
        "desc": "Papaya fresca de la región, rica en sabor y vitaminas.",
        "price": 20.0,
        "stock": 40,
        "image": "assets/images/papaya-maradol.png",
      },
      {
        "title": "Plátano criollo",
        "desc": "Plátano maduro cultivado de forma natural en la zona maya.",
        "price": 18.0,
        "stock": 60,
        "image": "assets/images/platano-criollo.png",
      },
      {
        "title": "Calabaza chayote",
        "desc": "Calabaza tierna de productores locales, ideal para guisos.",
        "price": 15.0,
        "stock": 45,
        "image": "assets/images/calabaza-chayote.png",
      },
      {
        "title": "Chile habanero",
        "desc": "Chile habanero fresco, picante y cultivado sin químicos.",
        "price": 10.0,
        "stock": 80,
        "image": "assets/images/chile-habanero.png",
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
            onViewMore: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Categoria2(
                    title: p["title"] as String,
                    image: p["image"] as String,
                    price: p["price"] as double,
                    description: p["desc"] as String,
                  ),
                ),
              );
            },
            onGoToShop: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
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
