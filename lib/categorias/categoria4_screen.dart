import 'package:flutter/material.dart';
import 'package:luumil_app/screens/perfil_screen.dart';
import 'package:luumil_app/widgets/search_bar_header.dart';

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

    const bg = Color.fromRGBO(244, 220, 197, 1);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            SearchBarHeader(
              onBack: () => Navigator.pop(context),
              onSearch: (value) {
                // si luego quieres filtro, aquí lo conectas
              },
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
                    onViewMore: () {},
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
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
