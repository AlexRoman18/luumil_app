import 'package:flutter/material.dart';
import 'package:luumil_app/navigation/bottom_nav_bar.dart';
import 'package:luumil_app/widgets/comer/activity_list.dart';
import 'package:luumil_app/widgets/comer/dashboard_header.dart';
import 'package:luumil_app/widgets/comer/stats_section.dart';
import 'package:luumil_app/widgets/side_menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const bg = Color.fromRGBO(244, 220, 197, 1); // cremita global
    const cardColor = Color.fromRGBO(255, 247, 238, 1); // cremita de cards

    return Scaffold(
      backgroundColor: bg,

      // Menú lateral (el mismo que usas en PantallaInicio)
      drawer: const SideMenu(),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),

        // 👉 degradado tipo PantallaInicio / perfil
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, bg],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        title: Text(
          'Panel de tienda',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          Icon(Icons.notifications_none, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 16),
        ],
      ),

      body: Stack(
        children: [
          // fondo cremita parejo
          const Positioned.fill(child: ColoredBox(color: bg)),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔶 Header principal (datos de la tienda)
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: DashboardHeader(),
                  ),
                ),

                const SizedBox(height: 20),

                // 📊 Stats en una tarjeta suave
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: StatsSection(),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Actividad reciente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                // 📰 Lista de actividad envuelta en fondo cremita
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ActivityList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
