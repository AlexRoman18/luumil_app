import 'package:flutter/material.dart';
import 'package:luumil_app/categorias/categoria2_screen.dart';
import 'package:luumil_app/categorias/categoria3_screen.dart';
import 'package:luumil_app/categorias/categoria4_screen.dart';
import 'package:luumil_app/categorias/categoria5_screen.dart';
import 'package:luumil_app/categorias/categoria6_screen.dart';
import 'package:luumil_app/screens/products_screen.dart';

class CategoriaScreen extends StatelessWidget {
  const CategoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const bg = Color.fromRGBO(244, 220, 197, 1); // fondo cálido global
    const cardColor = Color.fromRGBO(
      255,
      247,
      238,
      1,
    ); // fondo crema suave para tarjetas

    final categorias = [
      'Velas aromáticas',
      'Frutas y Verduras',
      'Maíz y Derivados',
      'Panadería y Repostería',
      'Limpieza y Hogar',
      'Dulcería y Snacks',
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
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 🔍 Barra de búsqueda estilo igual que PantallaInicio
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withOpacity(0.25),
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    hintText: 'Buscar...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🟫 Cuadrícula de categorías con el estilo de card unificado
              Expanded(
                child: GridView.builder(
                  itemCount: categorias.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.87,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.10,
                            ),
                          ),
                        ],
                      ),

                      // Contenido del card
                      child: Column(
                        children: [
                          // 📷 imagen
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

                          // 🔘 botón estilo unificado
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  elevation: 3,
                                  shadowColor: theme.colorScheme.onSurface
                                      .withOpacity(0.25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
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
                                      destino = const ProductsScreen();
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
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
