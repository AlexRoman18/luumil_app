import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/categorias/categoria2_screen.dart';
import 'package:luumil_app/categorias/categoria3_screen.dart';
import 'package:luumil_app/categorias/categoria4_screen.dart';
import 'package:luumil_app/categorias/categoria5_screen.dart';
import 'package:luumil_app/categorias/categoria6_screen.dart';
import 'package:luumil_app/screens/products_screen.dart';
import 'package:luumil_app/widgets/buttons.dart';

class CategoriaScreen extends StatelessWidget {
  const CategoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = [
      'Velas aromáticas',
      'Frutas y Verduras',
      'Maíz y Derivados',
      'Panadería y Repostería',
      'Limpieza y Hogar',
      'Dulcería y Snacks',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Campo de búsqueda
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
              const SizedBox(height: 25),
              // Cuadrícula de botones de categorías
              Expanded(
                child: GridView.builder(
                  itemCount: categorias.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(9),
                      child: SizedBox(
                        width: 200, // ajusta el ancho del contenido
                        height: 120, // ajusta la altura del contenedor
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 200, //Ajustar tamaños botones
                              height: 50,
                              child: Buttons(
                                color: const Color(0xFF007BFF),
                                text: categorias[index],
                                colorText: Colors.white,
                                onPressed: () {
                                  Widget destino;
                                  switch (index) {
                                    case 0:
                                      destino = const ProductsScreen();
                                      break;
                                    case 1:
                                      destino = const Categoria2Screen();
                                      break;
                                    case 2:
                                      destino = const Categoria3Screen();
                                      break;
                                    case 3:
                                      destino = const Categoria4Screen();
                                      break;
                                    case 4:
                                      destino = const Categoria5Screen();
                                      break;
                                    case 5:
                                      destino = const Categoria6Screen();
                                      break;
                                    default:
                                      destino =
                                          const ProductsScreen(); // pantalla por defecto si algo falla
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => destino,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
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
