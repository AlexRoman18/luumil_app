import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/categorias/categoria6_screen.dart';

class LocalidadScreen extends StatelessWidget {
  const LocalidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const bg = Color.fromRGBO(244, 220, 197, 1); // Fondo cálido
    const cardColor = Color.fromRGBO(255, 247, 238, 1); // Fondo crema (cards)

    final categorias = [
      'X-Hazil Sur',
      'Chunhuhub',
      'X-Pichil',
      'Noh-Bec',
      'Señor',
      'Tihosuco',
      'Tepich',
      'Chumpón',
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // 🌿 Barra de búsqueda estilo unificado
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
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
                    hintStyle: GoogleFonts.poppins(fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🟫 Grid de localidades con mismo estilo crema
              Expanded(
                child: GridView.builder(
                  itemCount: categorias.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.88,
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

                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 70,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.55,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 🔘 Botón estilo igual al de categorías
                          SizedBox(
                            width: double.infinity,
                            height: 45,
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
                                Widget destino = const Categoria6Screen();

                                // 👉 aquí luego agregas pantallas específicas
                                switch (index) {
                                  case 0:
                                    destino = const Categoria6Screen();
                                    break;
                                  default:
                                    destino = const Categoria6Screen();
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
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
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
