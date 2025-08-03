// Updated ChatScreen with fixed dynamic typing and safe null checks
// All usages of models are removed, and dynamic is used carefully

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_chat/services/socket_service.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';
import 'package:quick_chat/views/pages/CallingPage.dart';

import '../../provider/UserProvider.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final dynamic receiver;
  final bool isGroup;
  final String? groupName;

  const ChatScreen({
    Key? key,
    required this.roomId,
    required this.receiver,
    this.isGroup = false,
    this.groupName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  var userData;
  final player = AudioPlayer();
  final ScrollController scrollController = ScrollController();
  Timer? _messageRefreshTimer;
  dynamic replyingTo;

  late SocketService _socketService;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _dragExtent = 0.0;
  bool _isReplyTriggered = false;

  @override
  void initState() {
    super.initState();
    scrollToBottom();
    _initSocket(); // Initialize socket connection

    // Keep animation setup (unrelated to sockets)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.15, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Fetch initial messages (only once, no more polling)
    fetchMessages(widget.roomId);

    // Scroll to bottom after first render
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  Future<void> _initSocket() async {
    _socketService = await MyDio().getSocket();
    _socketService.joinRoom(widget.roomId);

    _socketService.onReceiveMessage((newMessage){
      setState(() {
        _messages.add(newMessage);
      });
      scrollToBottom();
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, dynamic message) {
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

  void onReplyMessage(dynamic message) {
    setState(() {
      replyingTo = message;
    });
  }

  Future<void> fetchMessages(String roomId) async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get("/chat/room/$roomId/messages");
      final List<dynamic> messageList = response.data;
      setState(() {
        _messages = messageList.reversed.toList();
        _isLoading = false;
      });
      scrollToBottom();
    } catch (e) {
      debugPrint("Error in fetchMessages: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch messages')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Optimistic UI update (message appears instantly)
    final tempMessage = {
      '_id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
      'content': content,
      'sender': {'_id': userData["_id"]},
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(tempMessage);
    });
    _messageController.clear();
    scrollToBottom();
    await player.play(AssetSource('sounds/sendMsgPopSound.mp3'));

    // Send via Socket.io (no need for HTTP)
    _socketService.sendMessage(
      roomId: widget.roomId,
      content: content,
      senderId: userData["_id"],
    );
  }

  // Future<void> _sendMessage() async {
  //   final content = _messageController.text.trim();
  //   if (content.isEmpty) return;
  //
  //   _socketService.sendMessage(roomId: widget.roomId, content: content, senderId: userData["_id"]);
  //
  //   try {
  //     final dio = await MyDio().getDio();
  //     final sendMsgUrl = widget.isGroup
  //         ? "/groups/sendGroupMessage"
  //         : "/chat/sendMessage";
  //
  //     final dataToSend = {
  //       "roomId": widget.roomId,
  //       "content": content,
  //       if (widget.isGroup) "senderId": userData["_id"],
  //     };
  //
  //     final response = await dio.post(sendMsgUrl, data: dataToSend);
  //
  //     _messageController.clear();
  //     await player.play(AssetSource('sounds/sendMsgPopSound.mp3'));
  //
  //     setState(() {
  //       _messages.add(response.data);
  //     });
  //
  //     scrollToBottom();
  //   } catch (e) {
  //     debugPrint("Message sending error: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Cannot send message')),
  //     );
  //   }
  // }

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
    // _socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    userData = userProvider.userData;
    debugPrint("receiver data from chat screen ${widget.receiver}");

    final displayName = widget.isGroup
        ? (widget.groupName ?? "Group Chat")
        : (widget.receiver?["username"] ?? 'Chat');

    debugPrint("receiver data in chat screen ${widget.isGroup ? widget.groupName : widget.receiver }");

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(displayName)),
          ],
        ),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.call)),
          IconButton(onPressed: (){
            final storedIds = userData["_id"];
            final callId = 'chat_$storedIds';

            Navigator.push(context, MaterialPageRoute(builder: (_) => Callingpage(callId: callId)));
          }, icon: Icon(Icons.videocam))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyChatState()
                : ListView.builder(
              controller: scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['sender']?['_id'] == userData['_id'];

                return GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onHorizontalDragUpdate(details, message),
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  child: ChatBubble(
                    message: message,
                    isMe: isMe,
                  ),
                );
              },
            ),
          ),
          if (replyingTo != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                    child: Text("Replying to: ${replyingTo?['content'] ?? ''}"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => replyingTo = null),
                  ),
                ],
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
            'No messages with ${widget.isGroup ? (widget.groupName ?? "Group") : (widget.receiver?['username'] ?? "Unknown")} yet',
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
