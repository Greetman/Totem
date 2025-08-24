import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          GlassContainer(
            borderRadius: 12,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Calendar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: GlassContainer(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: const Text(
                  'Calendar view coming soon...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
