import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:luumil_app/services/cache_service.dart';
import 'package:luumil_app/screens/usuario/chat_screen.dart';

class MensajesVendedorScreen extends StatefulWidget {
  const MensajesVendedorScreen({super.key});

  @override
  State<MensajesVendedorScreen> createState() => _MensajesVendedorScreenState();
}

class _MensajesVendedorScreenState extends State<MensajesVendedorScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _vendedorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Mensajes',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('vendedorId', isEqualTo: _vendedorId)
            .orderBy('ultimoTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes mensajes aún',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final chatId = chats[index].id;
              final usuarioId = chat['usuarioId'];
              final ultimoMensaje = chat['ultimoMensaje'] ?? '';
              final timestamp = chat['ultimoTimestamp'] as Timestamp?;

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('mensajes')
                    .where('leido', isEqualTo: false)
                    .where('senderId', isNotEqualTo: _vendedorId)
                    .snapshots(),
                builder: (context, mensajesSnapshot) {
                  final mensajesNoLeidos = mensajesSnapshot.hasData
                      ? mensajesSnapshot.data!.docs.length
                      : 0;
                  final hayNoLeidos = mensajesNoLeidos > 0;

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore
                        .collection('usuarios')
                        .doc(usuarioId)
                        .get(),
                    builder: (context, userSnapshot) {
                      String nombreUsuario = 'Usuario';
                      String? fotoUsuario;

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        nombreUsuario = userData['nombrePersonal'] ?? 'Usuario';
                        fotoUsuario = userData['fotoPerfil'];
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: hayNoLeidos ? 2 : 0,
                        color: hayNoLeidos ? Colors.blue[50] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: hayNoLeidos
                                ? const Color(0xFF007BFF).withValues(alpha: 0.3)
                                : Colors.grey[200]!,
                            width: hayNoLeidos ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF007BFF),
                                backgroundImage: fotoUsuario != null
                                    ? CachedNetworkImageProvider(
                                        fotoUsuario,
                                        cacheManager: CacheService.cacheManager,
                                      )
                                    : null,
                                child: fotoUsuario == null
                                    ? Text(
                                        nombreUsuario[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              if (hayNoLeidos)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF28A745),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            nombreUsuario,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: hayNoLeidos
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: hayNoLeidos
                                  ? Colors.black87
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            ultimoMensaje,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: hayNoLeidos
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: hayNoLeidos
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (timestamp != null)
                                Text(
                                  _formatearFecha(timestamp.toDate()),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: hayNoLeidos
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: hayNoLeidos
                                        ? const Color(0xFF007BFF)
                                        : Colors.grey[500],
                                  ),
                                ),
                              if (hayNoLeidos) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC3545),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    mensajesNoLeidos > 9
                                        ? '9+'
                                        : '$mensajesNoLeidos',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  vendedorId: usuarioId,
                                  vendedorNombre: nombreUsuario,
                                  esVendedor: true,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minuto = fecha.minute.toString().padLeft(2, '0');
      return '$hora:$minuto';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return '${diferencia.inDays}d';
    } else {
      return '${fecha.day}/${fecha.month}';
    }
  }
}
