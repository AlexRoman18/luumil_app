import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/screens/categorias/dulce_products_screen.dart';
import 'package:luumil_app/screens/categorias/frutas_products_screen.dart';
import 'package:luumil_app/screens/categorias/limpieza_products_screen.dart';
import 'package:luumil_app/screens/categorias/otros_products_screen.dart';
import 'package:luumil_app/screens/categorias/verdura_products_screen.dart';
import 'package:luumil_app/screens/categorias/zapatos_products_screen.dart';
import 'package:luumil_app/widgets/usuario/search_bar_header.dart';

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
              // 🔍 Flecha + buscador
              SearchBarHeader(
                onBack: () => Navigator.pop(context),
                onSearch: (value) {
                  // Aquí puedes implementar búsqueda si quieres
                },
              ),

              // 📌 Texto centrado con Google Fonts
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Explora los sabores y productos que se elabora',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16, // 👈 consistente con tus botones
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // 🟦 Cuadrícula de categorías
              Expanded(
                child: GridView.builder(
                  itemCount: categorias.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.88,
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
                                fit: BoxFit.contain,
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
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007BFF),
                                  elevation: 2,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
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
                                      destino = const VerduraProductsScreen();
                                      break;
                                    case 2:
                                      destino = const FrutasProductsScreen();
                                      break;
                                    case 3:
                                      destino = const LimpiezaProductsScreen();
                                      break;
                                    case 4:
                                      destino = const ZapatosProductsScreen();
                                      break;
                                    case 5:
                                      destino = const OthersProductsScreen();
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
                                    fontSize: 14,
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
