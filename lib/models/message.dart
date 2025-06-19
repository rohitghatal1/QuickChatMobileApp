import 'package:intl/intl.dart';

import 'user.dart';

class Message {
  final String id;
  final User sender;
  final User receiver;
  final String content;
  final DateTime timestamp;
  final bool read;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp'] ?? json['timeStamp']),
      read: json['read'],
    );
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(timestamp);
  }
}