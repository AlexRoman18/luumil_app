import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luumil_app/services/resena_service.dart';

class ResenasScreen extends StatefulWidget {
  final Map<String, dynamic> producto;

  const ResenasScreen({super.key, required this.producto});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  final ResenaService _resenaService = ResenaService();
  int _estrellasSeleccionadas = 0;
  final TextEditingController _comentarioController = TextEditingController();
  Resena? _miResena;
  bool _isLoadingMiResena = true;

  @override
  void initState() {
    super.initState();
    _cargarMiResena();
  }

  Future<void> _cargarMiResena() async {
    final resena = await _resenaService.obtenerMiResena(
      widget.producto['id'] ?? '',
    );
    if (mounted) {
      setState(() {
        _miResena = resena;
        if (resena != null) {
          _estrellasSeleccionadas = resena.estrellas;
          _comentarioController.text = resena.comentario ?? '';
        }
        _isLoadingMiResena = false;
      });
    }
  }

  Future<void> _guardarResena() async {
    if (_estrellasSeleccionadas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecciona al menos una estrella',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _resenaService.agregarResena(
      productoId: widget.producto['id'] ?? '',
      estrellas: _estrellasSeleccionadas,
      comentario: _comentarioController.text.trim().isEmpty
          ? null
          : _comentarioController.text.trim(),
    );

    if (mounted) {
      // Limpiar el formulario después de guardar
      _comentarioController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reseña guardada exitosamente',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _cargarMiResena();
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.producto['nombre'] ?? 'Producto';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reseñas',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Formulario para agregar/editar reseña
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _miResena == null ? 'Califica este producto' : 'Tu reseña',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Selector de estrellas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _estrellasSeleccionadas
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          _estrellasSeleccionadas = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // Campo de comentario
                TextField(
                  controller: _comentarioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario (opcional)',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF007BFF)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botón de guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardarResena,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _miResena == null
                          ? 'Publicar reseña'
                          : 'Actualizar reseña',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de reseñas
          Expanded(
            child: StreamBuilder<List<Resena>>(
              stream: _resenaService.obtenerResenas(
                widget.producto['id'] ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aún no hay reseñas',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Sé el primero en calificar!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final resenas = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: resenas.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final resena = resenas[index];
                    return _buildResenaItem(resena);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResenaItem(Resena resena) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Usuario y fecha
        Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
              child: Text(
                resena.userName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF007BFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resena.userName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatearFecha(resena.fecha),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Estrellas
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < resena.estrellas ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 18,
            );
          }),
        ),
        // Comentario
        if (resena.comentario != null && resena.comentario!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            resena.comentario!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);

    if (diferencia.inDays == 0) {
      if (diferencia.inHours == 0) {
        return 'Hace ${diferencia.inMinutes} min';
      }
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} d';
    } else if (diferencia.inDays < 30) {
      return 'Hace ${(diferencia.inDays / 7).floor()} sem';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
