import 'package:quick_chat/models/message.dart';

class ChatRoom {
  final String id;
  final String? name;
  final bool isGroup;
  final List<String> participants;
  final String? admin;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    this.name,
    required this.isGroup,
    required this.participants,
    this.admin,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt
});

  factory ChatRoom.fromJson(Map<String, dynamic> json){
    return ChatRoom(
      id: json['_id'],
      name: json['name'],
      isGroup: json['isGroup'],
      participants: List<String>.from(json['participants']),
      admin: json['admin'],
      lastMessage: json['lastMessage'] != null ? Message.fromJson(json['lastMessage']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}