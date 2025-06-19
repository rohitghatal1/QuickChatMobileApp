import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/models/message.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../utils/Dio/myDio.dart';
import '../auth/login_screen.dart';
import '../pages/my_profile.dart';
import '../pages/new_chat_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Message> _allMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getMyChats();
  }

  Future<void> _getMyChats() async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get("/chat/message/getMyMessages");

      if(response.data != null){
        final List<Message> messages = (response.data as List).map((json) => Message.fromJson(json)).toList();

        setState(() {
          _allMessages = messages;
          _isLoading = false;
        });
      }
      // Handle or parse response if needed
      print("Fetched chats: ${response.data}");
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No chats found")),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Logout'),
                value: 'logout',
              ),
              const PopupMenuItem(
                child: Text('My Profile'),
                value: 'myProfile',
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await _handleLogout(context);
              } else if (value == 'myProfile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allMessages.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        itemCount: _allMessages.length,
        itemBuilder: (context, index) {
          final message = _allMessages[index];
          return ListTile(
            leading: CircleAvatar(
                child: Text(
                  message.sender.username.isNotEmpty
                      ? message.sender.username[0].toUpperCase()
                      : '?',
                ),
            ),
            title: Text(message.content ?? "No message"),
            subtitle: Text('From : ${message.sender?.username ?? "Unknown"}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(user: message.receiver),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewChatScreen()),
          );
        },
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
}
