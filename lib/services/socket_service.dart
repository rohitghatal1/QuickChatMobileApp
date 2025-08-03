import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // Initialize socket connection
  void initSocket(String token) {
    socket = IO.io(
      'http://192.168.18.17:5000', // Match your backend URL
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) => print('Socket connected!'));
    socket.onDisconnect((_) => print('Socket disconnected'));
  }

  // Join a chat room
  void joinRoom(String roomId) {
    socket.emit('join_room', roomId);
  }

  // Send a message
  void sendMessage({
    required String roomId,
    required String content,
    required String senderId,
  }) {
    socket.emit('send_message', {
      'roomId': roomId,
      'content': content,
      'senderId': senderId,
    });
  }

  // Listen for incoming messages
  void onReceiveMessage(Function(dynamic) callback) {
    socket.on('receive_message', (data) => callback(data));
  }

  // Cleanup
  void dispose() {
    socket.disconnect();
    socket.off('receive_message');
  }
}