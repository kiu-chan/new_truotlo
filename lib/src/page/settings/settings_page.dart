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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _isLoggedIn
                    ? ListTile(
                        title: Text('Name: ${_userData['name'] ?? 'N/A'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${_userData['email'] ?? 'N/A'}'),
                            Text('Role: ${_userData['role'] ?? 'N/A'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Edit functionality not implemented yet')),
                            );
                          },
                        ),
                      )
                    : const ListTile(
                        title: Text('Đăng nhập để xem thông tin chi tiết'),
                        subtitle:
                            Text('Click vào nút Login ở dưới để đăng nhập'),
                      ),
                const Divider(),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.send),
                  title: const Text('Send Request'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SendRequestPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Information'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const InformationPage()),
                    );
                  },
                ),
                _isLoggedIn
                    ? ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: () async {
                          await _logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Logged out successfully')),
                          );
                          await Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const SelectPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      )
                    : ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('Login'),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                          if (result == true) {
                            await _loadUserData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Logged in successfully')),
                              );
                            }
                          }
                        },
                      ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'App Version: 1.0.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
