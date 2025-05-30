import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/views/auth/login_screen.dart';
import 'package:quick_chat/views/pages/my_profile.dart';
import 'package:quick_chat/views/pages/new_chat_screen.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/chat_controller.dart';
import '../../../models/user.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton(itemBuilder: (context) => [
            const PopupMenuItem(
              child: Text('Logout'),
              value: 'logout',
            ),
            PopupMenuItem(
                child: Text('My Profile'),
                value: 'myProfile',
            )
          ],
            onSelected: (value) async{
            if(value == 'logout'){
              await _handleLogout(context);
            } else if (value == 'myProfile'){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            }
            },
          )
        ],
      ),
      body: chatController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatController.users.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        itemCount: chatController.users.length,
        itemBuilder: (context, index) {
          final user = chatController.users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user.username[0].toUpperCase()),
            ),
            title: Text(user.username),
            subtitle: const Text('Tap to start chatting'),
            onTap: () {
              chatController.selectUser(user);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(user: user),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () => _showNewChatDialog(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('No chats yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewChatScreen()),
              );
            },
            child: const Text('START NEW CHAT'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);

    await authController.logout();
    chatController.dispose();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false);
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Chat'),
          content: const Text('Feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}