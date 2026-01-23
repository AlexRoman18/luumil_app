import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final ValueChanged<String> onSearch;

  const SearchBarHeader({
    super.key,
    required this.onBack,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      title: Container(
        height: 50, // 🔥 más alto que antes
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          onChanged: onSearch,
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Buscar...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
            ), // 🔥 más espacio interno
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
