import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SideMenu(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [NotificationBadge(), SizedBox(width: 8)],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(),
            SizedBox(height: 20),
            StatsSection(),
            SizedBox(height: 20),
            ActivityList(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
