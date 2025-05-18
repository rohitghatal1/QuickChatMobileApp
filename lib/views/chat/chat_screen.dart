import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/chat_controller.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final chatController = Provider.of<ChatController>(context, listen: false);
    chatController.sendMessage(_messageController.text.trim());
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final authController = Provider.of<AuthController>(context);
    final currentUserId = authController.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              reverse: true,
              itemCount: chatController.messages.length,
              itemBuilder: (context, index) {
                final message = chatController.messages.reversed.toList()[index];
                final isMe = message.sender.id == currentUserId;

                return ChatBubble(
                  message: message,
                  isMe: isMe,
                );
              },
            ),
          ),
          Padding(
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
          ),
        ],
      ),
    );
  }
}