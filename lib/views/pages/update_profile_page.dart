import 'package:flutter/material.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = await MyDio().getDio();
      final response = await dio.patch("/users/updateProfile", data: {
        'name': _nameController.text,
        'email': _emailController.text,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Prile updated successfylly")));
    } catch (e) {
      print("Failed to update profile: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
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
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (val) =>
                    val == null || val.isEmpty ? "Plese enter email" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: updateProfile,
                  child:
                      _isLoading ? CircularProgressIndicator() : Text("Updte"))
            ],
          ),
        ),
      ),
    );
  }
}
