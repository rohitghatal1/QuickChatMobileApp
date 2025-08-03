import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? icon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon, size: 18,),
        border: const OutlineInputBorder(),
      ),
      validator: validator,

    );
  }
}