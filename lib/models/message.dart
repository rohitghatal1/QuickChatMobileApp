import 'package:quick_chat/models/ChatRoom.dart';
import 'package:quick_chat/models/user.dart';

class Message {
  final String id;
  final ChatRoom chatRoom;
  final User sender;
  final String content;
  final List<String> readBy;
  final DateTime createAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.chatRoom,
    required this.sender,
    required this.content,
    required this.readBy,
    required this.createAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    ChatRoom chatRoom;
    if (json['chatRoom'] is String) {
      chatRoom = ChatRoom(
        id: json['chatRoom'],
        participants: [],
        lastMessage: null,
        isGroup: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      chatRoom = ChatRoom.fromJson(json['chatRoom']);
    }

    User sender;
    if (json['sender'] is String) {
      sender = User(
        id: json['sender'],
        name: '',
        username: '',
        number: '',
        email: '',
      );
    } else {
      sender = User.fromJson(json['sender']);
    }

    return Message(
      id: json['_id'],
      chatRoom: chatRoom,
      sender: sender,
      content: json['content'] ?? '[No content]', // <-- Prevents crash
      readBy: List<String>.from(json['readBy'] ?? []),
      createAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

}
