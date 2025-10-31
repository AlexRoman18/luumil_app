import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/screens/product_detail_screen.dart';
import 'package:luumil_app/screens/perfil_screen.dart';

class Categoria5Screen extends StatelessWidget {
  const Categoria5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "title": "Vela aaaa",
        "desc": "Vela con cera de abeja olor naranja",
        "price": 60.0,
        "stock": 34,
      },
      {
        "title": "Vela aromática de vainilla",
        "desc": "Vela natural con esencia de vainilla y cera vegetal",
        "price": 65.0,
        "stock": 28,
      },
      {
        "title": "Vela aromática de coco",
        "desc": "Vela artesanal con aroma tropical a coco fresco",
        "price": 70.0,
        "stock": 40,
      },
      {
        "title": "Vela aromática de canela",
        "desc": "Vela con notas cálidas de canela y cera de abeja pura",
        "price": 75.0,
        "stock": 25,
      },
      {
        "title": "Vela de lavanda relajante",
        "desc": "Vela con aroma a lavanda, ideal para relajación y descanso",
        "price": 80.0,
        "stock": 32,
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
