import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quick_chat/models/message.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';

import '../../../models/user.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final User receiver;
  final bool isGroup;
  final String? groupName;

  const ChatScreen(
      {Key? key,
      required this.roomId,
      required this.receiver,
      this.isGroup = false,
      this.groupName})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  late User currentUser;
  final player = AudioPlayer();
  final ScrollController scrollController = ScrollController();
  Timer? _messageRefreshTimer;
  Message? replyingTo;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  double _dragExtent = 0.0;
  bool _isReplyTriggered = false;

  @override
  void initState() {
    super.initState();
    getLoggedInUser();
    scrollToBottom();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0.15, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _messageRefreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchMessages(widget.roomId);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, Message message) {
    _dragExtent += details.primaryDelta ?? 0;
    if (_dragExtent > 60 && !_isReplyTriggered) {
      _isReplyTriggered = true;
      _controller.forward().then((_) {
        _controller.reverse();
        onReplyMessage(message);
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _dragExtent = 0;
    _isReplyTriggered = false;
  }

  void onReplyMessage(Message message) {
    setState(() {
      replyingTo = message;
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

      scrollToBottom();
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
      final sendMsgUrl =
          widget.isGroup ? "/groups/sendGroupMessage" : "/chat/sendMessage";
      final dataToSend = widget.isGroup
          ? {
              "roomId": widget.roomId,
              "content": content,
              "senderId": currentUser.id,
            }
          : {
              "roomId": widget.roomId,
              "content": content,
            };
      final response = await dio.post(sendMsgUrl, data: dataToSend);
      print('response received: ${response.data}');
      print('Type of data: ${response.data.runtimeType}');

      _messageController.clear();

      await player.play(AssetSource('sounds/sendMsgPopSound.mp3'));
      final newMessage = Message.fromJson(response.data);
      setState(() {
        _messages.insert(_messages.length, newMessage);
      });
      scrollToBottom();
    } catch (e) {
      print("Message sending error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send message')),
      );
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageRefreshTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(widget.isGroup
                  ? (widget.groupName?[0].toUpperCase() ?? "G")
                  : widget.receiver.username[0].toUpperCase()),
            ),
            const SizedBox(width: 10),
            Text(widget.isGroup
                ? widget.groupName ?? "Group Chat"
                : widget.receiver.username),
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
                          return SlideTransition(
                            position: _offsetAnimation,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) =>
                                  _onHorizontalDragUpdate(details, message),
                              onHorizontalDragEnd: _onHorizontalDragEnd,
                              child: ChatBubble(
                                message: message,
                                isMe: message.sender.id == currentUser.id,
                              ),
                            ),
                          );
                        },
                      ),
          ),

          if (replyingTo != null) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Row(
                children: [
                  Expanded(child: Text("Replying to: ${replyingTo!.content}")),
                  IconButton(
                      onPressed: () => setState(() => replyingTo = null),
                      icon: Icon(Icons.close)),
                ],
              ),
            )
          ],
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
