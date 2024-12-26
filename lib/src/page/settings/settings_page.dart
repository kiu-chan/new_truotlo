import 'package:flutter/material.dart';
import 'package:new_truotlo/src/page/account/login/login_page.dart';
import 'package:new_truotlo/src/page/settings/information_page.dart';
import 'package:new_truotlo/src/page/settings/send_request_page.dart';
import 'package:new_truotlo/src/select_page.dart';
import 'package:new_truotlo/src/user/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _isLoggedIn = false;
  Map<String, String?> _userData = {};
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadUserData() async {
    bool loggedIn = await UserPreferences.isLoggedIn();
    Map<String, String?> userData = await UserPreferences.getUser();
    setState(() {
      _isLoggedIn = loggedIn;
      _userData = userData;
    });
  }

  Future<void> _logout() async {
    await UserPreferences.clearUser();
    setState(() {
      _isLoggedIn = false;
      _userData = {};
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade600, Colors.blue.shade400],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 45,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoggedIn ? (_userData['name'] ?? 'N/A') : 'Welcome, Guest',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_isLoggedIn) ...[
                        const SizedBox(height: 4),
                        Text(
                          _userData['email'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Role: ${_userData['role'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ] else
                        const Text(
                          'Login to access all features',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              )
            : null,
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[600],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildSettingsItem(
                  icon: Icons.send_rounded,
                  title: 'Send Request',
                  subtitle: 'Submit a new request or inquiry',
                  iconColor: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SendRequestPage(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.info_rounded,
                  title: 'Information',
                  subtitle: 'About us and app details',
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InformationPage(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: _isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                  title: _isLoggedIn ? 'Logout' : 'Login',
                  subtitle: _isLoggedIn
                      ? 'Sign out of your account'
                      : 'Sign in to your account',
                  iconColor: _isLoggedIn ? Colors.red : Colors.blue,
                  onTap: _isLoggedIn
                      ? () async {
                          await _logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logged out successfully'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          await Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const SelectPage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                          if (result == true) {
                            await _loadUserData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logged in successfully'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'App Version: $_appVersion',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Designed by GIRC - TUAF',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}