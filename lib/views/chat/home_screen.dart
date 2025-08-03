import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/models/user.dart';
import 'package:quick_chat/services/socket_service.dart';
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
  List<dynamic> _chatRooms = [];
  bool _isLoading = true;
  var userData;
  late SocketService _socketService;

  final player = AudioPlayer();
  Map<String, String?> _previousLastMessageIds = {};

  Timer? _chatRoomRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchMyChatRooms();

  }

  Future<void> _initSocket() async {
    _socketService = await MyDio().getSocket();
    _socketService.onReceiveMessage((_) async{
      await _fetchMyChatRooms();
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    // _socketService.dispose();
    super.dispose();
  }

  Future<void> _fetchMyChatRooms() async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get("/chat/room/getMyChatRooms");

      if (response.data != null) {
        final List<dynamic> rooms = response.data;

        for (final room in rooms) {
          final lastMessage = room['lastMessage'];
          final lastMessageId = lastMessage != null ? lastMessage['_id'] : null;

          if (lastMessageId != null) {
            final oldId = _previousLastMessageIds[room['_id']];
            if (oldId != null && oldId != lastMessageId) {
              await player.play(AssetSource("sounds/vibratingReceiveSound.mp3"));
            }
            _previousLastMessageIds[room['_id']] = lastMessageId;
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
            final isGroup = room['isGroup'] ?? false;
            final groupName = room['name'] ?? 'Group Chat';
            List<dynamic> participants = room['participants'] ?? [];
            final lastMessage = room['lastMessage'];
            final receiver = lastMessage != null ? lastMessage['receiver'] : null;

            String displayName = 'Unknown';

            if (isGroup) {
              displayName = groupName;
            } else {
              final currentUserId = userData["_id"];
              final otherUser = participants.firstWhere(
                    (user) => user['_id'] != currentUserId,
                orElse: () => null,
              );

              if (otherUser != null) {
                displayName = otherUser['username'] ??
                    otherUser['name'] ??
                    (receiver != null ? receiver['username'] ?? 'Unknown' : 'Unknown');
              } else if (receiver != null) {
                displayName = receiver['username'] ?? 'Unknown';
              }
            }

            final avatarText = (displayName is String && displayName.isNotEmpty)
                ? displayName[0].toUpperCase()
                : '?';

            final subtitle = (lastMessage?['content'] ?? 'No messages yet') as String;

            return ListTile(
              leading: CircleAvatar(child: Text(avatarText)),
              title: Text(displayName),
              subtitle: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                // In the HomeScreen's ListTile onTap, change this:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      roomId: room['_id'],
                      receiver: isGroup
                          ? null
                          : (receiver),
                      isGroup: isGroup,
                      groupName: isGroup ? groupName : null, // Add this line
                    ),
                  ),
                );
              },
            );
          }

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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
