import 'package:flutter/material.dart';
import 'package:quick_chat/widgets/custom_textfield.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  final _currentPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(controller: _currentPasswordController, label: "Current Password")
              ],
        )),
      ),
    );
  }
}
