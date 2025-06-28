import 'package:flutter/material.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';
import 'package:quick_chat/views/pages/my_profile.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final dio = await MyDio().getDio();
      final response = await dio.patch("/users/changePassword", data: {
        'currentPassword': currentPasswordController.text,
        'newPassword': newPasswordController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password changed successfully")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (cotext) => ProfileScreen()),
      );
    } catch (e) {
      print("Error changing password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to change password")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (val) => val == null || val.isEmpty
                    ? 'Current password required'
                    : null,
              ),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New password'),
                obscureText: true,
                validator: (val) => val == null || val.length < 6
                    ? 'Minimum 6 chats required'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _isLoading ? null : changePassword,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Change Password'))
            ],
          ),
        ),
      ),
    );
  }
}
