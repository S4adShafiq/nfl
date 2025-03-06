import 'package:flutter/material.dart';
import 'package:nflapp/newsscreen.dart';
import 'standings.dart';
import 'matches.dart';
import 'teams_screen.dart';
import 'stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default tab (News)
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Static Background Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Color(0xFF0A1931),
                Colors.black,
              ], // Black-Navy-Black Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Main UI
        Scaffold(
          extendBodyBehindAppBar:
              true, // Ensures gradient covers the full screen
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/splash.png', // Adjust the path if needed
                  height: 30, // Adjust size as needed
                ),
                const SizedBox(width: 8), // Space between logo and text
                const Text(
                  "NFL",
                  style: TextStyle(
                    fontFamily: 'Baseball',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),

          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              const Matches(),
              const TeamsScreen(),
              const NewsScreen(),
              const Stats(),
              const Live(),
            ],
          ),
          bottomNavigationBar: _buildSlantedNavBar(),
          backgroundColor: Colors.transparent, // Ensure background stays static
        ),
      ],
    );
  }


  Widget _buildSlantedNavBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1931), Colors.black], // Navy to Black
          begin: Alignment.topLeft, // Slanted direction
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent, // Background is now the gradient
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_football),label: 'Matches',),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.stadium), label: 'Live'),
        ],
      ),
    );
  }
}
