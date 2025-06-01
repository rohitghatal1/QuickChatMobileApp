import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:fluttertoast/fluttertoast.dart';

import '../config/constants.dart';
import '../models/message.dart';
import '../models/user.dart';

class SocketService {
  late io.Socket socket;
  Function(Message)? onMessageReceived;

  void initializeSocket(String token) {
    socket = io.io(
      AppConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) {
      print('Socket connected');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.onError((error) {
      Fluttertoast.showToast(msg: 'Socket error: $error');
    });

    socket.on('receiveMessage', (data) {
      if (onMessageReceived != null) {
        final message = Message.fromJson(data);
        onMessageReceived!(message);
      }
    });
  }

  void joinConversation(String userId) {
    socket.emit('joinConversation', {'userId': userId});
  }

  void sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    socket.emit('sendMessage', [senderId, receiverId, content]);
  }

  void disconnect() {
    socket.disconnect();
  }
}