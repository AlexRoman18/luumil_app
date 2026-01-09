import 'package:flutter/material.dart';
import 'package:luumil_app/widgets/comer/activity_item.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'name': 'Angel Adriel',
        'action': 'Le dió Me gusta',
        'image': 'https://i.pravatar.cc/100?img=1',
      },
      {
        'name': 'Alexandra Román',
        'action': 'Empezó a seguirte',
        'image': 'https://i.pravatar.cc/100?img=2',
      },
      {
        'name': 'Angel Adriel',
        'action': 'Le dió Me gusta',
        'image': 'https://i.pravatar.cc/100?img=3',
      },
      {
        'name': 'Alexandra Román',
        'action': 'Empezó a seguirte',
        'image': 'https://i.pravatar.cc/100?img=4',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad reciente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...activities.map(
          (a) => ActivityItem(
            name: a['name']!,
            action: a['action']!,
            imageUrl: a['image']!,
          ),
        ),
      ],
    );
  }
}
