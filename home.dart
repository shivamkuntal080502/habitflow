import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(HabitFlowApp());
}

class HabitFlowApp extends StatefulWidget {
  @override
  _HabitFlowAppState createState() => _HabitFlowAppState();
}

class _HabitFlowAppState extends State<HabitFlowApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow',
      // Use the selected theme.
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HabitFlowMainPage(
        isDarkMode: isDarkMode,
        onThemeChanged: (bool value) {
          setState(() {
            isDarkMode = value;
          });
        },
      ),
    );
  }
}

/// Main page that holds the AppBar, bottom navigation bar, and three tabs:
/// Home, Profile, and Settings.
class HabitFlowMainPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HabitFlowMainPage({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _HabitFlowMainPageState createState() => _HabitFlowMainPageState();
}

class _HabitFlowMainPageState extends State<HabitFlowMainPage> {
  int _selectedIndex = 0;
  late final String _userId;
  final GlobalKey<HomeTabState> _homeTabKey = GlobalKey<HomeTabState>();

  @override
  void initState() {
    super.initState();
    // Generate a random user ID (between 1000 and 9999).
    final random = Random();
    _userId = 'User${random.nextInt(9000) + 1000}';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _titles = ['HabitFlow', 'Profile', 'Settings'];

  @override
  Widget build(BuildContext context) {
    // Build pages list on every build to update theme settings.
    final pages = [
      HomeTab(key: _homeTabKey),
      ProfileTab(userId: _userId),
      SettingsTab(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: pages[_selectedIndex],
      // Show the FAB only on the Home tab.
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _homeTabKey.currentState?.addHabit();
              },
              child: Icon(Icons.add),
              tooltip: 'Add Habit',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

/// Home Tab: Displays a slider with quotes/fun facts and an interactive habit list.
class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  // List of current habits.
  List<String> habits = ["Meditation", "Reading", "Exercise"];

  // Quotes and fun facts regarding habits.
  final List<String> sliderItems = [
    "Quote: We are what we repeatedly do. Excellence, then, is not an act, but a habit. – Aristotle",
    "Fun Fact: It takes on average 66 days to form a new habit.",
    "Quote: Motivation is what gets you started. Habit is what keeps you going.",
    "Fun Fact: Repeating a habit daily can lead to significant personal growth over a year.",
  ];

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoSlide();
  }

  /// Automatically advances the slider every 10 seconds.
  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      setState(() {
        _currentPage = (_currentPage + 1) % sliderItems.length;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  /// Public method to add a new habit.
  void addHabit() {
    setState(() {
      habits.add("New Habit ${habits.length + 1}");
    });
  }

  void _removeHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    _currentPage = (_currentPage + 1) % sliderItems.length;
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Welcome to HabitFlow",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Track and improve your daily habits with ease.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Slider with quotes/fun facts.
          Container(
            height: 150,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: sliderItems.length,
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              sliderItems[index],
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Left arrow button.
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Center(
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: _previousPage,
                    ),
                  ),
                ),
                // Right arrow button.
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                      onPressed: _nextPage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Habit list.
          Expanded(
            child: habits.isEmpty
                ? const Center(
                    child: Text(
                      "No habits yet. Tap '+' to add one!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(habits[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeHabit(index),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Clicked on ${habits[index]}"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
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

/// Profile Tab: Displays the random user ID.
class ProfileTab extends StatelessWidget {
  final String userId;

  const ProfileTab({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Page\nYour User ID: $userId',
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Settings Tab: Provides a switch to toggle between dark and light mode.
class SettingsTab extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsTab({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SwitchListTile(
          title: const Text("Dark Mode"),
          value: isDarkMode,
          onChanged: onThemeChanged,
        ),
      ],
    );
  }
}
