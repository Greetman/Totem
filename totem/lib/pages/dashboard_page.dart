import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Mock streak value for now. Replace with real data source later.
  int _currentStreakDays = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Streak counter
                Row(
                  children: [
                    _buildStreakBadge(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current streak',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_currentStreakDays days',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentStreakDays++;
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      tooltip: 'Increment (demo)',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Keep logging workouts daily to increase your streak. This is a placeholder UI — connect your real data source next.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge() {
    final pct = (_currentStreakDays % 7) / 7.0;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_currentStreakDays',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
