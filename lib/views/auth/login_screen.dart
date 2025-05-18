import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../controllers/auth_controller.dart';
import '../chat/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);

    final int? number = int.tryParse(_numberController.text.trim());
    if(number == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number'))
      );
      return;
    }
    await authController.login(
      number: number,
      password: _passwordController.text.trim(),
    );

    if (authController.currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: _numberController,
                label: 'Number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<AuthController>(
                builder: (context, authController, _) {
                  return CustomButton(
                    onPressed: authController.isLoading ? null : _login,
                    text: 'Login',
                    isLoading: authController.isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}