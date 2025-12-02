import 'package:flutter/material.dart';
import 'package:luumil_app/screens/perfil_screen.dart';
import 'package:luumil_app/widgets/search_bar_header.dart';

class Categoria3Screen extends StatelessWidget {
  const Categoria3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "title": "Tortillas de maíz nixtamalizado",
        "desc": "Tortillas hechas a mano con maíz criollo de la región",
        "price": 30.0,
        "stock": 100,
        "image": "assets/images/tortillas-maiz.png",
      },
      {
        "title": "Pinole artesanal",
        "desc":
            "Harina de maíz tostado con canela y azúcar, ideal para bebidas",
        "price": 45.0,
        "stock": 35,
        "image": "assets/images/pinole-artesanal.png",
      },
      {
        "title": "Pozol tradicional",
        "desc": "Bebida refrescante a base de maíz molido y cacao natural",
        "price": 25.0,
        "stock": 50,
        "image": "assets/images/pozol-tradicional.png",
      },
      {
        "title": "Elote fresco",
        "desc": "Mazorca tierna cosechada por productores locales",
        "price": 10.0,
        "stock": 70,
        "image": "assets/images/elote-fresco.png",
      },
      {
        "title": "Tostadas de maíz",
        "desc": "Crujientes y naturales, perfectas para antojitos mexicanos",
        "price": 20.0,
        "stock": 60,
        "image": "assets/images/tostadas-maiz.png",
      },
    ];

    final theme = Theme.of(context);
    const bg = Color.fromRGBO(244, 220, 197, 1);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 MISMA BARRA DE BÚSQUEDA QUE EN LAS DEMÁS
            SearchBarHeader(
              onBack: () => Navigator.pop(context),
              onSearch: (value) {
                // aquí luego puedes agregar filtro si quieres
              },
            ),

            // 🔹 Lista de productos
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
    const cardColor = Color.fromRGBO(255, 247, 238, 1);

    return Card(
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.06 * 255).round(),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
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

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onViewMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 20,
                            ),
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            "Ver más",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onGoToShop,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 20,
                            ),
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            "Tienda",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
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
