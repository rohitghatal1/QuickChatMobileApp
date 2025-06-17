import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_controller.dart';
import '../../models/user.dart';
import '../../utils/Dio/myDio.dart';
import '../chat/chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  List<User> _allUsers = [];

  @override
  void initState() {
    super.initState();
    getUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> getUsers() async{
    try{
      final response = await (await (MyDio().getDio())).get("/users/getUsers");
      if (response.data != null) {
        final List<User> users = (response.data as List).map((json) => User.fromJson(json)).toList();

        setState(() {
          _allUsers = users;
          _filteredUsers = users;
        });
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error fetching users")));
    }
  }


  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Expanded(
            child: chatController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(user.username[0].toUpperCase()),
                            ),
                            title: Text(user.username),
                            subtitle: Text(user.email),
                            onTap: () {
                              if (user.id.isEmpty) {
                                print('Invalid user data: $user');
                                return;
                              }
                              final chatController =
                                  context.read<ChatController>();
                              chatController.selectUser(user);
                              print("navigating with user: ${user.id}");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(user: user),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
