import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/screens/product_detail_screen.dart';
import 'package:luumil_app/screens/perfil_screen.dart';

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
      },
      {
        "title": "Pinole artesanal",
        "desc":
            "Harina de maíz tostado con canela y azúcar, ideal para bebidas",
        "price": 45.0,
        "stock": 35,
      },
      {
        "title": "Pozol tradicional",
        "desc": "Bebida refrescante a base de maíz molido y cacao natural",
        "price": 25.0,
        "stock": 50,
      },
      {
        "title": "Elote fresco",
        "desc": "Mazorca tierna cosechada por productores locales",
        "price": 10.0,
        "stock": 70,
      },
      {
        "title": "Tostadas de maíz",
        "desc": "Crujientes y naturales, perfectas para antojitos mexicanos",
        "price": 20.0,
        "stock": 60,
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
            onViewMore: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductDetailScreen(),
                ),
              );
            },
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
  final VoidCallback onViewMore;
  final VoidCallback onGoToShop;

  const _ProductCard({
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
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
            // Imagen
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.grayBackground,
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/vela.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Información
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

                  // Botones
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
                            "Ir al perfil de la tienda",
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
