import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/comer/perfil_header.dart';
import 'package:luumil_app/widgets/comer/perfil_post_card.dart';
import 'package:luumil_app/widgets/comer/perfil_section.dart';
import 'package:luumil_app/widgets/comer/perfil_header_background.dart';
import 'package:luumil_app/widgets/comer/horario_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PerfilHeaderBackground(),
            const ProfileHeader(),

            // 🏷️ Nuestra Historia
            const ProfileSection(
              title: 'Nuestra Historia',
              icon: Icons.edit_outlined,
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),

            // 🕒 Horarios
            const ProfileSection(
              title: 'Horarios',
              icon: Icons.schedule_outlined,
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HorarioRow(dia: 'Lunes a viernes', hora: '9:00 AM - 6:00 PM'),
                  HorarioRow(dia: 'Sábados', hora: '9:00 AM - 2:00 PM'),
                  HorarioRow(dia: 'Domingos', hora: 'Cerrado'),
                ],
              ),
            ),

            // 📰 Publicaciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Publicaciones",
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const ProfilePostCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
