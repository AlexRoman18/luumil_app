import 'package:flutter/material.dart';
import 'package:luumil_app/screens/perfil_screen.dart';
import 'package:luumil_app/verMas_categories/categoria2.dart';
import 'package:luumil_app/widgets/search_bar_header.dart';

class Categoria6Screen extends StatelessWidget {
  const Categoria6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "title": "Mazapanes de cacahuate",
        "desc": "Mazapanes artesanales hechas con cacahuate natural",
        "price": 60.0,
        "stock": 34,
        "image": "assets/images/mazapan.png",
      },
      {
        "title": "Caramelos de miel",
        "desc": "Caramelos suaves elaborados con miel pura",
        "price": 65.0,
        "stock": 28,
        "image": "assets/images/miel.png",
      },
      {
        "title": "Palanquetas de cacahuete",
        "desc": "Palanquetas crujientes hechas con cacahuate y miel",
        "price": 70.0,
        "stock": 40,
        "image": "assets/images/palanquetas.png",
      },
      {
        "title": "Dulce de papaya",
        "desc": "Dulce tradicional hecho con papaya natural y azúcar",
        "price": 75.0,
        "stock": 25,
        "image": "assets/images/dulcePapaya.png",
      },
      {
        "title": "Cocadas",
        "desc": "Cocadas frescas elaboradas con coco rallado y azúcar",
        "price": 80.0,
        "stock": 32,
        "image": "assets/images/cocada.png",
      },
    ];

    final theme = Theme.of(context);
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
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.12 * 255).round(),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.6 * 255).round(),
                    ),
                  ),
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
