import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/models/user.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';
import 'package:quick_chat/views/pages/create_group_page.dart';
import '../../provider/UserProvider.dart';
import '../../models/ChatRoom.dart';
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
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  var userData;

  final player = AudioPlayer();
  Map<String, String?> _previousLastMessageIds = {};

  Timer? _chatRoomRefreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchMyChatRooms();

    _chatRoomRefreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchMyChatRooms();
    });
  }

  @override
  void dispose() {
    _chatRoomRefreshTimer?.cancel();
    super.dispose();
  }



  Future<void> _fetchMyChatRooms() async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get("/chat/room/getMyChatRooms");

      if (response.data != null) {
        final List<ChatRoom> rooms = (response.data as List)
            .map((json) => ChatRoom.fromJson(json))
            .toList();

        for (final room in rooms) {
          final lastMessageid = room.lastMessage?.id;

          if (lastMessageid != null) {
            final oldId = _previousLastMessageIds[room.id];
            if (oldId != null && oldId != lastMessageid) {
              await player
                  .play(AssetSource("sounds/vibratingReceiveSound.mp3"));
            }

            _previousLastMessageIds[room.id] = lastMessageid;
          }
        }

        setState(() {
          _chatRooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("error fetching rooms $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch chat rooms")),
      );
    }
  }

  // Helper function to get the other participant in a 1:1 chat
  User? _getOtherParticipant(ChatRoom room) {
    if (room.participants.length < 2) return null;

    // Assuming you have the current user's ID stored
    if (userData["_id"] == null) return null;

    try {
      return room.participants.firstWhere(
        (user) => user.id != userData["_id"],
        orElse: () => room.participants.first,
      );
    } catch (e) {
      return room.participants.isNotEmpty ? room.participants.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    userData = userProvider.userData;
    debugPrint("userData in home screen $userData");
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
                child: Text('Create new Group'),
                value: 'createGroup',
              ),
              const PopupMenuItem(
                child: Text('My Profile'),
                value: 'myProfile',
              ),
              const PopupMenuItem(
                child: Text('Logout'),
                value: 'logout',
              ),
            ],

            onSelected: (value) async {
              if (value == 'logout') {
                await _handleLogout(context);
              } else if (value == 'myProfile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (value == 'createGroup') {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateGroupPage()));
              }
            },
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = _chatRooms[index];
                    final otherUser = _getOtherParticipant(room);

                    if (otherUser == null) {
                      return const ListTile(
                        title: Text('Unknown user'),
                      );
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          otherUser.username.isNotEmpty
                              ? otherUser.username[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(room.isGroup
                          ? "Group Chat"
                          : otherUser.username.isNotEmpty
                              ? otherUser.username
                              : otherUser.name.isNotEmpty
                                  ? otherUser.name
                                  : 'Unknown'),
                      subtitle: Text(
                        room.lastMessage?.content ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              roomId: room.id,
                              receiver: otherUser,
                              isGroup: room.isGroup,
                            ),
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
            MaterialPageRoute(builder: (_) => const NewChatScreen()),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('No chat rooms yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewChatScreen()),
              );
            },
            child: const Text('START NEW CHAT'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Clear storage, token or auth info here if needed
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
