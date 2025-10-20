import 'package:flutter/material.dart';
import 'package:luumil_app/config/theme/app_colors.dart';
import 'package:luumil_app/screens/product_detail_screen.dart';
import 'package:luumil_app/screens/perfil_screen.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final int stock;
  final VoidCallback onViewMore;
  final VoidCallback onGoToShop;

  const ProductCard({
    super.key,
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProductDetailScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white, // 👈 texto blanco
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white, // 👈 texto blanco
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            
                            ),
                          ),
                          child: const Text( "Ir al perfil de la tienda" ,style: TextStyle(
                            fontSize: 12
                          ),),
                          
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
