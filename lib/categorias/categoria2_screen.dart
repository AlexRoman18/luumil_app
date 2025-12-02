import 'package:flutter/material.dart';
import 'package:luumil_app/screens/perfil_screen.dart';
import 'package:luumil_app/widgets/search_bar_header.dart';

class Categoria2Screen extends StatefulWidget {
  const Categoria2Screen({super.key});

  @override
  State<Categoria2Screen> createState() => _Categoria2ScreenState();
}

class _Categoria2ScreenState extends State<Categoria2Screen> {
  // Productos base
  final List<Map<String, dynamic>> _products = [
    {
      "title": "Piña miel",
      "desc": "Piña cultivada en huertos locales, jugosa y naturalmente dulce",
      "price": 25.0,
      "stock": 50,
      "image": "assets/images/pina-miel.png",
    },
    {
      "title": "Papaya maradol",
      "desc": "Papaya fresca de la región, rica en sabor y vitaminas",
      "price": 20.0,
      "stock": 40,
      "image": "assets/images/papaya-maradol.png",
    },
    {
      "title": "Plátano criollo",
      "desc": "Plátano maduro cultivado de forma natural en la zona maya",
      "price": 18.0,
      "stock": 60,
      "image": "assets/images/platano-criollo.png",
    },
    {
      "title": "Calabaza chayote",
      "desc": "Calabaza tierna de productores locales, ideal para guisos",
      "price": 15.0,
      "stock": 45,
      "image": "assets/images/calabaza-chayote.png",
    },
    {
      "title": "Chile habanero",
      "desc": "Chile habanero fresco, picante y cultivado sin químicos",
      "price": 10.0,
      "stock": 80,
      "image": "assets/images/chile-habanero.png",
    },
  ];

  late List<Map<String, dynamic>> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_products);
  }

  void _filterProducts(String value) {
    final query = value.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products.where((p) {
          final title = (p['title'] as String).toLowerCase();
          final desc = (p['desc'] as String).toLowerCase();
          return title.contains(query) || desc.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color.fromRGBO(244, 220, 197, 1);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Barra de búsqueda con botón back
            SearchBarHeader(
              onBack: () => Navigator.pop(context),
              onSearch: _filterProducts,
            ),

            // 🔹 Lista de productos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final p = _filteredProducts[index];
                  return _ProductCard(
                    title: p["title"] as String,
                    description: p["desc"] as String,
                    price: p["price"] as double,
                    stock: p["stock"] as int,
                    image: p["image"] as String,
                    onViewMore: () {},
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final int stock;
  final String image;
  final VoidCallback onViewMore;
  final VoidCallback onGoToShop;

  const _ProductCard({
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    required this.onViewMore,
    required this.onGoToShop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Cremita un poco más claro que el fondo
    const cardColor = Color.fromRGBO(255, 247, 238, 1);

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // 🟠 Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.06 * 255).round(),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.12 * 255).round(),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.6 * 255).round(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 🟠 Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título un poco más chico
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Costo: \$${price.toStringAsFixed(2)} c/u",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  Text(
                    "Disponible: $stock piezas",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // 🟠 Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onViewMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Ver más'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onGoToShop,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Tienda',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 15, // 👈 AJUSTA EL TAMAÑO AQUÍ
                              color: theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w600,
                            ),
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
