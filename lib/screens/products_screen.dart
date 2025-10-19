import 'package:flutter/material.dart';
import '../widgets/search_bar_header.dart';
import '../widgets/product_list.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchBarHeader(
              onBack: () => Navigator.pop(context),
              onSearch: (value) {},
            ),
            const Expanded(child: ProductList()),
          ],
        ),
      ),
    );
  }
}
