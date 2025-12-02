import 'package:flutter/material.dart';

class ProductDescription extends StatelessWidget {
  final String title;
  final String description;

  const ProductDescription({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withAlpha((0.87 * 255).round())),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}
