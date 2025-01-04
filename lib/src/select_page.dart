import 'package:flutter/material.dart';
import 'package:new_truotlo/src/page/home/home_page.dart';
import 'package:new_truotlo/src/page/chart/chart_page.dart';
import 'package:new_truotlo/src/page/map/map_page.dart';
import 'package:new_truotlo/src/page/mangage/manage_page.dart';
import 'package:new_truotlo/src/page/settings/settings_page.dart';
import 'package:new_truotlo/src/user/auth_service.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  SelectPageState createState() => SelectPageState();
}

class SelectPageState extends State<SelectPage> with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  int _currentIndex = 0;
  late AnimationController _controller;

  // Định nghĩa màu chủ đạo
  final Color _primaryGreen = const Color(0xFF4CAF50);
  final Color _lightGreen = const Color(0xFF81C784);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      bool loggedIn = await UserPreferences.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const MapPage(),
      if (_isLoggedIn) const ManagePage(),
      const ChartPage(),
      const SettingsPage(),
    ];

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          onTap: (int index) {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
                _controller.reset();
                _controller.forward();
              });
            }
          },
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          selectedItemColor: _primaryGreen,
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          items: [
            _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
            _buildNavItem(Icons.map_outlined, Icons.map_rounded, 'Map'),
            if (_isLoggedIn)
              _buildNavItem(Icons.manage_accounts_outlined, Icons.manage_accounts_rounded, 'Manage'),
            _buildNavItem(Icons.ssid_chart_outlined, Icons.ssid_chart_rounded, 'Chart'),
            _buildNavItem(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    final bool isSelected = _currentIndex == _getItemIndex(label);
    
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? _lightGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _lightGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          activeIcon,
          size: 28,
          color: _primaryGreen,
        ),
      ),
      label: label,
    );
  }

  int _getItemIndex(String label) {
    switch (label) {
      case 'Home':
        return 0;
      case 'Map':
        return 1;
      case 'Manage':
        return 2;
      case 'Chart':
        return _isLoggedIn ? 3 : 2;
      case 'Settings':
        return _isLoggedIn ? 4 : 3;
      default:
        return 0;
    }
  }
}