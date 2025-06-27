import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quick_chat/models/message.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';

import '../../../models/user.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final User receiver;

  const ChatScreen({Key? key, required this.roomId, required this.receiver})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  late User currentUser;

  Timer? _messageRefreshTimer;

  @override
  void initState() {
    super.initState();
    getLoggedInUser();

    _messageRefreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchMessages(widget.roomId);
    });
  }


  Future<void> getLoggedInUser() async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get("/users/auth/me");
      setState(() {
        currentUser = User.fromJson(response.data);
      });
      fetchMessages(widget.roomId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch current user data')),
      );
    }
  }

  Future<void> fetchMessages(String roomId) async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get("/chat/room/$roomId/messages");


      // Parse the response
      final List<dynamic> messageList = response.data;

      // Convert each message
      final List<Message> messages = messageList.map((messageJson) {
        try {
          return Message.fromJson(messageJson);
        } catch (e, stack) {
          print("Error parsing message $messageJson: $e\n$stack");
          throw e; // Re-throw to catch in outer block
        }
      }).toList();

      print("Successfully parsed ${messages.length} messages");
      setState(() {
        _messages = messages.reversed.toList();
        _isLoading = false;
      });
    } catch (e, stack) {
      print("Error in fetchMessages: $e\n$stack");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch messages: ${e.toString()}')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      final dio = await MyDio().getDio();
      final response = await dio.post("/chat/sendMessage", data: {
        "roomId": widget.roomId,
        "content": content,
      });
      print('response received: ${response.data}');
      print('Type of data: ${response.data.runtimeType}');

      _messageController.clear();

      final newMessage = Message.fromJson(response.data);
      setState(() {
        _messages.insert(0, newMessage);
      });
    } catch (e) {
      print("Message sending error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send message')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(widget.receiver.username[0].toUpperCase()),
            ),
            const SizedBox(width: 10),
            Text(widget.receiver.username),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyChatState()
                : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  isMe: message.sender.id == currentUser.id,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No messages with ${widget.receiver.username} yet',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text('Send your first message!'),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
