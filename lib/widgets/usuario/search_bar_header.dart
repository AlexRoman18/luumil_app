import 'package:flutter/material.dart';

class SearchBarHeader extends StatelessWidget {
  final VoidCallback onBack;
  final ValueChanged<String>? onSearch;

  const SearchBarHeader({
    super.key,
    required this.onBack,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: onSearch,
            ),
          ),
        ],
      ),
    );
  }
}
