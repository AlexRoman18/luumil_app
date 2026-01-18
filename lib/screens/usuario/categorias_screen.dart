import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/screens/categorias/dulce_products_screen.dart';
import 'package:luumil_app/screens/categorias/frutas_products_screen.dart';
import 'package:luumil_app/screens/categorias/limpieza_products_screen.dart';
import 'package:luumil_app/screens/categorias/otros_products_screen.dart';
import 'package:luumil_app/screens/categorias/verdura_products_screen.dart';
import 'package:luumil_app/screens/categorias/zapatos_products_screen.dart';

class CategoriaScreen extends StatelessWidget {
  const CategoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = [
      'Dulces',
      'Verduras',
      'Frutas',
      'Limpieza',
      'Zapatos',
      'Otros',
    ];

    final imagenes = [
      'assets/images/velas-aromaticas.png',
      'assets/images/Frutas-y-Verduras.png',
      'assets/images/Maiz-y-derivados.png',
      'assets/images/Panaderia-y-Reposteria.png',
      'assets/images/Limpieza-y-Hogar.png',
      'assets/images/dulcería-y-snacks.png',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // 🔍 Barra de búsqueda
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar...',
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🟦 Cuadrícula de categorías
              Expanded(
                child: GridView.builder(
                  itemCount: categorias.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.88, // 🔥 Más pequeño y balanceado
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          // 👉 Imagen más pequeña
                          Expanded(
                            flex: 5,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.asset(
                                imagenes[index],
                                width: double.infinity,
                                fit: BoxFit
                                    .contain, // 🔥 NO recorta y se ve más limpio
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height:
                                  44, // 🔥 Intermedio (no muy alto, no muy pequeño)
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007BFF),
                                  elevation: 2,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      18,
                                    ), // 🔥 Curvatura moderna
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                onPressed: () {
                                  Widget destino;
                                  switch (index) {
                                    case 0:
                                      destino = const DulcesScreen();
                                      break;
                                    case 1:
                                      destino =
                                          const VerduraProductsScreen(); // Verduras está en posición 1
                                      break;
                                    case 2:
                                      destino =
                                          const FrutasProductsScreen(); // Frutas está en posición 2
                                      break;
                                    case 3:
                                      destino =
                                          const LimpiezaProductsScreen(); // Limpieza está en posición 3
                                      break;
                                    case 4:
                                      destino =
                                          const ZapatosProductsScreen(); // Zapatos está en posición 4
                                      break;
                                    case 5:
                                      destino =
                                          const OthersProductsScreen(); // Otros está en posición 5
                                      break;
                                    default:
                                      destino = const DulcesScreen();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => destino,
                                    ),
                                  );
                                },
                                child: Text(
                                  categorias[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        14, // 🔥 Más grande para que se vea bonito
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
