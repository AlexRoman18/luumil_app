import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<Color> colors;

  const ColorSelector({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Colores disponibles",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: colors
              .map(
                (color) => Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
