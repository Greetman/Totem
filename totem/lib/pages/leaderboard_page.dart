import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sample = List.generate(
      8, // Number of leaderboard entries
      (i) => {'name': 'Player ${i + 1}', 'score': '${(15 - i * 0.15)} TONs'},
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            borderRadius: 12,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Top Weight Moved',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: sample.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = sample[index];
                return GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${entry['score']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
