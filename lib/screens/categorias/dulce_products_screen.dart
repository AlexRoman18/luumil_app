import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/screens/usuario/perfil_screen.dart';
import 'package:luumil_app/screens/usuario/product_detail_screen.dart';
import 'package:luumil_app/widgets/usuario/product_card.dart';
import '../../widgets/usuario/search_bar_header.dart';

class DulcesScreen extends StatefulWidget {
  const DulcesScreen({super.key});

  @override
  State<DulcesScreen> createState() => _DulcesScreenState();
}

class _DulcesScreenState extends State<DulcesScreen> {
  String? subcategoriaSeleccionada;

  final List<String> subcategorias = [
    'Todas',
    'Chocolate',
    'Caramelos',
    'Gomitas',
    'Paletas',
    'Otros dulces',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchBarHeader(
              onBack: () => Navigator.pop(context),
              onSearch: (value) {
                // Aquí puedes implementar búsqueda si quieres
              },
            ),

            // 🔹 Header con categoría y filtro
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: subcategorias.length,
                  itemBuilder: (context, index) {
                    final subcategoria = subcategorias[index];
                    final isSelected =
                        subcategoriaSeleccionada == subcategoria ||
                        (subcategoriaSeleccionada == null &&
                            subcategoria == 'Todas');

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(subcategoria),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            subcategoriaSeleccionada = subcategoria == 'Todas'
                                ? null
                                : subcategoria;
                          });
                        },
                        selectedColor: const Color(0xFF007BFF),
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('productos')
                    .where('categoria', isEqualTo: 'Dulces')
                    .orderBy('fecha', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error al cargar productos"),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filtrar por subcategoría
                  var productos = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (!data.containsKey('fecha') || data['fecha'] == null) {
                      return false;
                    }

                    // Filtro de subcategoría
                    if (subcategoriaSeleccionada != null) {
                      final subcategoria = data['subcategoria'] as String?;
                      return subcategoria == subcategoriaSeleccionada;
                    }

                    return true;
                  }).toList();

                  if (productos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No hay productos en esta subcategoría',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final data =
                          productos[index].data() as Map<String, dynamic>;

                      return ProductCard(
                        title: data['nombre'] ?? '',
                        description: data['descripcion'] ?? '',
                        price: (data['precio'] ?? 0).toDouble(),
                        stock: data['stock'] ?? 0,
                        imageUrl: (data['fotos'] as List).isNotEmpty
                            ? (data['fotos'] as List).first
                            : null,
                        pasos: data['pasos'] as List<dynamic>?,
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
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
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
