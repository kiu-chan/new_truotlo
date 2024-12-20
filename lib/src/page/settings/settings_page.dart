import 'package:flutter/material.dart';
import 'package:new_truotlo/src/page/account/login/login_page.dart';
import 'package:new_truotlo/src/page/settings/information_page.dart';
import 'package:new_truotlo/src/page/settings/send_request_page.dart';
import 'package:new_truotlo/src/select_page.dart';
import 'package:new_truotlo/src/user/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _isLoggedIn = false;
  Map<String, String?> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                size: 35,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _isLoggedIn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData['email'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Role: ${_userData['role'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, Guest',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Login to access all features',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (iconColor ?? Colors.blue).withOpacity(0.1),
          child: Icon(icon, color: iconColor ?? Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600]),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        color: Colors.blue,
        child: RefreshIndicator(
          onRefresh: _loadUserData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileCard(),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildSettingsItem(
                                icon: Icons.send,
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
                                icon: Icons.info,
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
                                icon: _isLoggedIn ? Icons.logout : Icons.login,
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
                                              ),
                                            );
                                          }
                                        }
                                      },
                              ),
                              const Spacer(),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    'App Version: 1.0.0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}