import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _handle = 'user_handle';
  String _bio = 'This is your bio. Edit to tell people about yourself.';
  int _totalPoints = 1240;
  int _clanRank = 7;

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
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.brown.shade400,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _handle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _editHandle,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _bio,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total points',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_totalPoints',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clan rank',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '#$_clanRank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GlassContainer(
            borderRadius: 12,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Activity', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.fitness_center,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Workouts',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    '23 this week',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.emoji_events,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Achievements',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    '2 new',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.06),
              ),
              child: const Text('Edit profile'),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile() async {
    // placeholder: open an edit dialog or page
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        final handleController = TextEditingController(text: _handle);
        final bioController = TextEditingController(text: _bio);
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Edit profile',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: handleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Handle',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: bioController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop({
                'handle': handleController.text,
                'bio': bioController.text,
              }),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _handle = result['handle'] ?? _handle;
        _bio = result['bio'] ?? _bio;
      });
    }
  }

  void _editHandle() {
    _editProfile();
  }
}
