import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';

import '../../../controllers/chat_controller.dart';
import '../../../models/user.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();


  Future<void> _sendMessage() async{
    final content = _messageController.text.trim();
    if(content.isEmpty) return;

    try{
      final response = await (await(MyDio().getDio())).post("/chat/sendMessage", data: {
        "receiverId" : widget.user.id,
        "content": content,
      });

      _messageController.clear();
  } catch(e){
      print("message sending error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot send message')),
      );
  }
}
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(widget.user.username[0].toUpperCase()),
            ),
            const SizedBox(width: 10),
            Text(widget.user.username),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: chatController.messages.isEmpty
                ? _buildEmptyChatState()
                : ListView.builder(
              reverse: true,
              itemCount: chatController.messages.length,
              itemBuilder: (context, index) {
                final message = chatController.messages.reversed.toList()[index];
                return ChatBubble(
                  message: message,
                  isMe: message.sender.id == chatController.currentUserId,
                );
              },
            ),
          ),
          _buildMessageInput(chatController),
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
            'No messages with ${widget.user.username} yet',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text('Send your first message!'),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatController chatController) {
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
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }

}