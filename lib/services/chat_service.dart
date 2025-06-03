import '../models/message.dart';
import '../models/user.dart';

class ChatService {
  Future<List<User>> getUsers(String token) async {
    throw UnimplementedError();
  }

  Future<List<Message>> getMessages(String token, String userId) async {
    // This will be implemented in the ChatController
    throw UnimplementedError();
  }
}