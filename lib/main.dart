import 'package:flutter/material.dart';
import 'package:luumil_app/screens/products_screen.dart';
import 'screens/home_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuumilApp',
      debugShowCheckedModeBanner: false, 
      home: const ProductsScreen());
  }
}

