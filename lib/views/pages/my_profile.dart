import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';
import 'package:quick_chat/views/pages/change_password_page.dart';
import 'package:quick_chat/views/pages/update_profile_page.dart';

import '../../controllers/auth_controller.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool _isLoading = true;

  Future<void> getLoggedInUserData() async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get('/users/auth/me');
      setState(() {
        user = response.data;
        _isLoading = false;
      });
    } catch (e) {
      print("error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching users')));
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);

    await authController.logout();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false);
  }

  @override
  void initState() {
    super.initState();
    getLoggedInUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? CircularProgressIndicator()
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                children: [
                  Text(
                    user!['name'][0],
                    style: TextStyle(fontSize: 25),
                  ),
                  Text(
                    user!['name'] ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    user!['number'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    user!['email'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Divider(height: 32),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Change Password'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () async {
                      final updated = Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordPage()),
                      );
                      if (updated == true) {
                        getLoggedInUserData();
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person_outlined),
                    title: Text('Update Profile'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () async {
                      final updated = Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProfilePage()),
                      );

                      if (updated == true) {
                        getLoggedInUserData();
                      }
                    },
                  ),
                  ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _handleLogout(context))
                ],
              ),
            ),
    );
  }
}
