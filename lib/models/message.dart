class Message {
  final String id;
  final String chatRoom;
  final String sender;
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

  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      id: json['_id'],
      chatRoom: json['chatRoom'],
      sender: json['sender'],
      content: json['content'] ?? '',
      readBy: List<String>.from(json['readBy']),
      createAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}