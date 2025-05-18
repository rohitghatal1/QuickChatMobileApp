import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/chat_controller.dart';
import '../../../models/user.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatController>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final chatController = Provider.of<ChatController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: chatController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chatController.users.length,
        itemBuilder: (context, index) {
          final user = chatController.users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user.username[0].toUpperCase()),
            ),
            title: Text(user.username),
            subtitle: Text(user.email),
            onTap: () {
              chatController.selectUser(user);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}