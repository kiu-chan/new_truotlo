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
  int currentindex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

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
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    bool loggedIn = await UserPreferences.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HomePage(),
      const MapPage(),
      if (_isLoggedIn) const ManagePage(),
      const ChartPage(),
      const SettingsPage(),
    ];

    return Scaffold(
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
          color: Colors.white,
          key: ValueKey<int>(currentindex),
          child: pages[currentindex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.green.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BottomNavigationBar(
            onTap: (int index) {
              setState(() {
                currentindex = index;
                _controller.reset();
                _controller.forward();
              });
            },
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            currentIndex: currentindex,
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
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: currentindex == _getItemIndex(label) 
              ? _lightGreen.withOpacity(0.1) 
              : Colors.transparent,
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