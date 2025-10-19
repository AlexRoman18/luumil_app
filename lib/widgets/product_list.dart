import 'package:flutter/material.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        "title": "Vela aromática",
        "desc": "Vela con cera de abeja olor naranja",
        "price": 60.0,
        "stock": 34,
      },
      {
        "title": "Vela aromática",
        "desc": "Vela con cera de abeja olor naranja",
        "price": 60.0,
        "stock": 34,
      },
      {
        "title": "Vela aromática",
        "desc": "Vela con cera de abeja olor naranja",
        "price": 60.0,
        "stock": 34,
      },
      {
        "title": "Vela aromática",
        "desc": "Vela con cera de abeja olor naranja",
        "price": 60.0,
        "stock": 34,
      },
    ];

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return ProductCard(
          title: p["title"] as String,
          description: p["desc"] as String,
          price: p["price"] as double,
          stock: p["stock"] as int,
          onViewMore: () {},
          onGoToShop: () {},
        );
      },
    );
  }
}
