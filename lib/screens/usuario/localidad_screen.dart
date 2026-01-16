import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/widgets/usuario/buttons.dart';

class LocalidadScreen extends StatelessWidget {
  const LocalidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // 🔍 Campo de búsqueda
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

              // 🟦 Grid de localidades
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
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 150,
                        height: 130,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 210,
                              height: 45,
                              child: Buttons(
                                color: const Color(0xFF007BFF),
                                text: categorias[index],
                                colorText: Colors.white,

                                onPressed: () {
                                  //  Widget destino = const Categoria6Screen();

                                  switch (index) {
                                    case 0:
                                      //  destino = const Categoria6Screen();
                                      break;
                                    case 1:
                                      //   destino = const ChunhuhubScreen();
                                      break;
                                    case 2:
                                      //   destino = const XPichilScreen();
                                      break;
                                    case 3:
                                      //    destino = const NohBecScreen();
                                      break;
                                    case 4:
                                      //     destino = const SenorScreen();
                                      break;
                                    case 5:
                                      //     destino = const TihosucoScreen();
                                      break;
                                    case 6:
                                      //      destino = const TepichScreen();
                                      break;
                                    case 7:
                                      //       destino = const ChumponScreen();
                                      break;
                                    default:
                                    //        destino = const XHazilScreen();
                                  }

                                  //  Navigator.push(
                                  //    context,
                                  //    MaterialPageRoute(
                                  //     builder: (context) => destino,
                                  //     ),
                                  //   );
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
