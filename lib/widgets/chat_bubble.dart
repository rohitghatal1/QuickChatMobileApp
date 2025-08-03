import 'package:flutter/material.dart';
import '../config/serverTimeToLocal.dart';

class ChatBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message["content"],
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    servertoLocalTime(message["createdAt"]),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message['read'] != null
                          ? Icons.done_all
                          : Icons.done,
                      size: 12,
                      color: message['read'] != null
                          ? Colors.blue[100]
                          : Colors.grey[200],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}