import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'pages/search_page.dart';
import 'pages/calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white, size: 28),
                  const Text(
                    'TOTEM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown.shade400,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const ClampingScrollPhysics(),
                pageSnapping: true,
                children: [DashboardPage(), SearchPage(), CalendarPage()],
              ),
            ),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
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
                            ? Colors.white
                            : Colors.grey.shade600,
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
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 36,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _onBottomNavTap(2),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.calendar_today,
                        color: _selectedIndex == 2
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
