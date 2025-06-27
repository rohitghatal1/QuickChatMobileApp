import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);

    await authController.logout();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    //sample data
    final String name = 'Rohit Ghatal';
    final int number = 980645229;
    final String email = 'rohitghatal@gmail.com';

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/quickChatImage.png'),
            ),
            Text(
              name,
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$number',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,
            ),
            Text(
              email,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,
            ),
            Divider(height: 32),

            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16,),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _handleLogout(context)
            )
          ],
        ),
      ),
    );
  }
}