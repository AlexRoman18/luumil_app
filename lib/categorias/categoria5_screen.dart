import 'package:flutter/material.dart';
import 'package:luumil_app/screens/perfil_screen.dart';
import 'package:luumil_app/verMas_categories/categoria2.dart';
import 'package:luumil_app/widgets/search_bar_header.dart';

class Categoria5Screen extends StatelessWidget {
  const Categoria5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "title": "Aromatizante de lavanda",
        "desc": "Spray natural con esencia de lavanda para ambientes",
        "price": 100.0,
        "stock": 22,
        "image": "assets/images/spray-lavanda.png",
      },
      {
        "title": "Incienso de sándalo",
        "desc": "Varitas de incienso hechas a mano con aroma a sándalo",
        "price": 70.0,
        "stock": 28,
        "image": "assets/images/incienso-png.png",
      },
      {
        "title": "Detergente ecológico de coco",
        "desc": "Detergente biodegradable hecho con extracto de coco",
        "price": 300.0,
        "stock": 40,
        "image": "assets/images/detergente-coco.png",
      },
      {
        "title": "Jabón artesanal para trastes",
        "desc": "Jabón líquido hecho a mano con ingredientes naturales",
        "price": 40.0,
        "stock": 25,
        "image": "assets/images/jabon-artesanal.png",
      },
      {
        "title": "Paño multiusos de bambú",
        "desc": "Paño reutilizable hecho con fibra de bambú ecológica",
        "price": 80.0,
        "stock": 15,
        "image": "assets/images/pañoBambu.png",
      },
    ];

    const bg = Color.fromRGBO(244, 220, 197, 1);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            SearchBarHeader(
              onBack: () => Navigator.pop(context),
              onSearch: (value) {},
            ),
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    const cardColor = Color.fromRGBO(255, 247, 238, 1); // cremita del card

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 110,
                height: 110,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.06 * 255).round(),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.12 * 255).round(),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.6 * 255).round(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Costo: \$${price.toStringAsFixed(2)} c/u",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Disponible: $stock piezas",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onViewMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            "Tienda",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSecondary,
                            ),
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
