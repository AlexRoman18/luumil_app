import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luumil_app/screens/usuario/perfil_screen.dart';
import 'package:luumil_app/screens/usuario/product_detail_screen.dart';
import 'package:luumil_app/widgets/usuario/product_card.dart';
import '../../widgets/usuario/search_bar_header.dart';

class ZapatosProductsScreen extends StatelessWidget {
  const ZapatosProductsScreen({super.key});

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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('productos')
                    .where('categoria', isEqualTo: 'Zapatos') // 👈 filtro
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

                  final productos = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data.containsKey('fecha') && data['fecha'] != null;
                  }).toList();

                  return ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final data =
                          productos[index].data() as Map<String, dynamic>;
                      print("Pantalla zapato recibió: ${data['categoria']}");

                      return ProductCard(
                        title: data['nombre'] ?? '',
                        description: data['descripcion'] ?? '',
                        price: (data['precio'] ?? 0).toDouble(),
                        stock: data['stock'] ?? 0,
                        imageUrl: (data['fotos'] as List).isNotEmpty
                            ? (data['fotos'] as List).first
                            : null,
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
