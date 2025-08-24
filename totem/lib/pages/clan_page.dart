import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/glass_container.dart';

class ClanPage extends StatefulWidget {
  const ClanPage({super.key});

  @override
  State<ClanPage> createState() => _ClanPageState();
}

class _ClanPageState extends State<ClanPage> {
  late List<Map<String, dynamic>> clans;
  final Set<int> _joined = {};

  @override
  void initState() {
    super.initState();
    clans = List.generate(6, (i) {
      return {'name': 'Test ${i + 1}', 'members': 10 + i, 'code': '${i + 1}'};
    });
  }

  Future<void> _showJoinDialog(int index) async {
    final controller = TextEditingController();
    final clan = clans[index];

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Join ${clan['name']}',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Material(
                color: Colors.transparent,
                child: GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  blur: 8,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(ctx).size.width * 0.85,
                      minWidth: 280,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join ${clan['name']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter invite code to join',
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Invite code',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final input = controller.text.trim();
                                if (input.isEmpty) return;
                                final valid =
                                    input.toUpperCase() ==
                                    (clan['code'] as String).toUpperCase();
                                Navigator.of(ctx).pop(valid);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                              ),
                              child: const Text('Join'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _joined.add(index);
        clans[index]['members'] = (clans[index]['members'] as int) + 1;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Joined successfully')));
    } else if (result == false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid code')));
    }
  }

  Future<void> _showCreateClanDialog() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Create Clan',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Material(
                color: Colors.transparent,
                child: GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  blur: 8,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(ctx).size.width * 0.85,
                      minWidth: 280,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Clan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Clan name',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: codeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Invite code',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final name = nameController.text.trim();
                                final code = codeController.text.trim();
                                if (name.isEmpty || code.isEmpty) return;
                                Navigator.of(ctx).pop(true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                              ),
                              child: const Text('Create'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (result == true) {
      setState(() {
        clans.add({
          'name': nameController.text.trim(),
          'members': 1,
          'code': codeController.text.trim(),
        });
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Clan created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            borderRadius: 12,
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _showCreateClanDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: 'Create clan',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: clans.length,
              itemBuilder: (context, index) {
                final clan = clans[index];
                final joined = _joined.contains(index);
                return GlassContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clan['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${clan['members']} members',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          joined
                              ? ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade700,
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Joined'),
                                )
                              : ElevatedButton(
                                  onPressed: () => _showJoinDialog(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    minimumSize: const Size(64, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Join'),
                                ),
                        ],
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
