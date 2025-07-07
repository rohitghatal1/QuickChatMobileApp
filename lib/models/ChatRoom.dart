import 'package:quick_chat/models/message.dart';
import 'package:quick_chat/models/user.dart';

class ChatRoom {
  final String id;
  final List<User> participants;
  final Message? lastMessage;
  final bool isGroup;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.isGroup,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    List<User> participants = [];
    if (json['participants'] is List) {
      participants = (json['participants'] as List).map((participant) {
        if (participant is String) {
          // If participant is just an ID string, create a minimal User object
          return User(
            id: participant,
            name: '',
            username: '',
            number: '',
            email: '',
          );
        } else {
          // If participant is a full user object
          return User.fromJson(participant);
        }
      }).toList();
    }

    return ChatRoom(
      id: json['_id'],
      participants: participants,
      lastMessage: (json['lastMessage'] is Map<String, dynamic>)
          ? Message.fromJson(json['lastMessage'])
          : null,
      isGroup: json['isGroup'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
