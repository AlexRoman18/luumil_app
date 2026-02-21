import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luumil_app/navigation/bottom_nav_bar.dart';
import 'package:luumil_app/widgets/comer/activity_list.dart';
import 'package:luumil_app/widgets/comer/dashboard_header.dart';
import 'package:luumil_app/widgets/comer/stats_section.dart';
import 'package:luumil_app/widgets/usuario/notification_badge.dart';
import 'package:luumil_app/widgets/usuario/side_menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavBar(
      dashboardContent: Scaffold(
        backgroundColor: Colors.grey[50],
        drawer: const SideMenu(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: const [NotificationBadge(), SizedBox(width: 16)],
        ),
        extendBodyBehindAppBar: false,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 4,
          tooltip: 'Asistente IA',
          onPressed: () => context.push('/history-chat'),
          child: const Text(
            'IA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[50]!, Colors.white],
            ),
          ),
          child: const SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(),
                SizedBox(height: 24),
                StatsSection(),
                SizedBox(height: 32),
                ActivityList(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
