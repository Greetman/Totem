import 'package:flutter/material.dart';
// removed dart:math (no longer using random selection)
import 'dart:ui';
import 'widgets/glass_container.dart';
import 'pages/dashboard_page.dart';
import 'pages/search_page.dart';
import 'pages/leaderboard_page.dart';
import 'pages/clan_page.dart';
import 'pages/profile_page.dart';
import 'pages/loading_page.dart';
import 'pages/sign_in_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isSignedIn = false;

  void _onLoadingComplete() {
    setState(() {
      _isLoading = false;
    });
  }

  void _onSignInSuccess() {
    setState(() {
      _isSignedIn = true;
    });
  }

  void _onSignOut() {
    setState(() {
      _isSignedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOTEM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: _isLoading
          ? LoadingPage(onLoadingComplete: _onLoadingComplete)
          : _isSignedIn
              ? MainPage(onSignOut: _onSignOut)
              : SignInPage(onSignInSuccess: _onSignInSuccess),
    );
  }
}

// GlassContainer moved to lib/widgets/glass_container.dart

class MainPage extends StatefulWidget {
  final VoidCallback onSignOut;

  const MainPage({super.key, required this.onSignOut});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  String _backgroundImage = 'background_image/Gradient.png'; // Default value
  bool _useBlackIcons = false;
  final List<Map<String, Object>> _backgroundOptions = [
    {
      'path': 'background_image/Gradient.png',
      'useBlack': false,
      'name': 'Cozmic',
    },
    {
      'path': 'background_image/Gradient1.png',
      'useBlack': true,
      'name': 'Plasma',
    },
    {
      'path': 'background_image/Gradient2.png',
      'useBlack': false,
      'name': 'Dawn',
    },
    {
      'path': 'background_image/Gradient3.png',
      'useBlack': false,
      'name': 'Granite',
    },
    {
      'path': 'background_image/Gradient4.png',
      'useBlack': false,
      'name': 'Infernus',
    },
    {
      'path': 'background_image/Gradient5.png',
      'useBlack': true,
      'name': 'Dune',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );
    // start with default background; user can choose one in Settings
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    // Animate to the tapped page and update the selected index when the
    // PageView reports the page change (in _onPageChanged). This avoids
    // immediately toggling the icon color on tap before the transition
    // completes.
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showSettingsDialog() async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        String selectedPath = _backgroundImage;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Center(
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: StatefulBuilder(
                  builder: (ctx2, setStateLocal) {
                    return GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
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
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Background',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            // Dropdown selection for backgrounds
                            Builder(
                              builder: (ctx3) {
                                final items = _backgroundOptions.map((opt) {
                                  final path = (opt['path'] as String?) ?? '';
                                  final name =
                                      (opt['name'] as String?) ??
                                      path.split('/').last;
                                  return DropdownMenuItem<String>(
                                    value: path,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 40,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            image: path.isNotEmpty
                                                ? DecorationImage(
                                                    image: AssetImage(path),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                            color: path.isEmpty
                                                ? Colors.grey.shade800
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList();

                                return DropdownButtonFormField<String>(
                                  value: selectedPath.isNotEmpty
                                      ? selectedPath
                                      : null,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors.grey.shade900,
                                  items: items,
                                  onChanged: (v) {
                                    if (v == null) return;
                                    // find selected option safely
                                    final matching = _backgroundOptions
                                        .cast<Map<String, Object?>>()
                                        .firstWhere(
                                          (o) => (o['path'] as String?) == v,
                                          orElse: () => {
                                            'path': '',
                                            'useBlack': false,
                                            'name': '',
                                          },
                                        );
                                    final useBlack =
                                        (matching['useBlack'] as bool?) ??
                                        false;
                                    setStateLocal(() {
                                      selectedPath = v;
                                    });
                                    setState(() {
                                      _backgroundImage = v;
                                      _useBlackIcons = useBlack;
                                    });
                                  },
                                  iconEnabledColor: Colors.white,
                                  style: const TextStyle(color: Colors.white),
                                  isExpanded: true,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(true);
                                },
                                child: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    // optional: handle result if needed
    if (result == true) {
      // closed with explicit action
    }
  }

  Future<void> _showProfilePage() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Center(
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(ctx).size.width * 0.9,
                      maxHeight: MediaQuery.of(ctx).size.height * 0.8,
                      minWidth: 300,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: ProfilePage(onSignOut: widget.onSignOut)),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Semi-transparent overlay to darken slightly
          Container(color: Colors.black.withOpacity(0.25)),

          SafeArea(
            child: AnimatedPadding(
              // Adjust padding when keyboard (viewInsets) appears to avoid
              // RenderFlex overflow at the bottom.
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              duration: const Duration(milliseconds: 250),
              child: Column(
                children: [
                  // Header with glass
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _showSettingsDialog,
                            icon: Icon(
                              Icons.menu,
                              color: _useBlackIcons
                                  ? Colors.black
                                  : Colors.white,
                              size: 28,
                            ),
                            tooltip: 'Settings',
                          ),
                          Text(
                            'TOTEM',
                            style: TextStyle(
                              color: _useBlackIcons
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showProfilePage,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.brown.shade400,
                              ),
                              child: Icon(
                                Icons.person,
                                color: _useBlackIcons
                                    ? Colors.black
                                    : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page View wrapped with padding and glass card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      child: GlassContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(8),
                        blur: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: _onPageChanged,
                            physics: const ClampingScrollPhysics(),
                            pageSnapping: true,
                            children: [
                              DashboardPage(),
                              SearchPage(),
                              LeaderboardPage(),
                              ClanPage(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Navigation with glass
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      blur: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () => _onBottomNavTap(0),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.home,
                                color: _selectedIndex == 0
                                    ? (_useBlackIcons
                                          ? Colors.black
                                          : Colors.white)
                                    : Colors.grey.shade400,
                                size: 36,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _onBottomNavTap(1),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.search,
                                color: _selectedIndex == 1
                                    ? (_useBlackIcons
                                          ? Colors.black
                                          : Colors.white)
                                    : Colors.grey.shade400,
                                size: 36,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _onBottomNavTap(2),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.emoji_events,
                                color: _selectedIndex == 2
                                    ? (_useBlackIcons
                                          ? Colors.black
                                          : Colors.white)
                                    : Colors.grey.shade400,
                                size: 36,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _onBottomNavTap(3),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.group,
                                color: _selectedIndex == 3
                                    ? (_useBlackIcons
                                          ? Colors.black
                                          : Colors.white)
                                    : Colors.grey.shade400,
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
