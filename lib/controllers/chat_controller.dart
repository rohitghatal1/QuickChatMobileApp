import 'package:flutter/material.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/auth_service.dart';

class ChatController with ChangeNotifier {
  final ApiService apiService;
  final SocketService socketService;
  final AuthService authService;

  ChatController({
    required this.apiService,
    required this.socketService,
    required this.authService,
  }) {
    _initializeSocket();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<User> _users = [];
  List<User> get users => _users;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  User? _selectedUser;
  User? get selectedUser => _selectedUser;

  void _initializeSocket() {
    final token = authService.getToken();
    if (token != null) {
      socketService.initializeSocket(token);
      socketService.onMessageReceived = (message) {
        if (_selectedUser != null &&
            (message.sender.id == _selectedUser!.id || message.receiver.id == _selectedUser!.id)) {
          _messages.add(message);
          notifyListeners();
        }
      };
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = authService.getToken();
      if (token != null) {
        final response = await apiService.get('/chat/users', token: token);
        _users = (response as List).map((user) => User.fromJson(user)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectUser(User user) async {
    _selectedUser = user;
    _messages = [];
    notifyListeners();

    await fetchMessages(user.id);

    final userId = authService.getUserId();
    if (userId != null) {
      socketService.joinConversation(userId);
    }
  }

  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = authService.getToken();
      if (token != null) {
        final response = await apiService.get('/chat/messages/$userId', token: token);
        _messages = (response as List).map((msg) => Message.fromJson(msg)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (_selectedUser == null) return;

    final senderId = authService.getUserId();
    if (senderId == null) return;

    final message = Message(
      id: '', // Will be set by server
      sender: User(id: senderId, name: '', email: '', username: '', number: ''),
      receiver: _selectedUser!,
      content: content,
      timestamp: DateTime.now(),
      read: false,
    );

    _messages.add(message);
    notifyListeners();

    socketService.sendMessage(
      senderId: senderId,
      receiverId: _selectedUser!.id,
      content: content,
    );
  }

  void dispose() {
    socketService.disconnect();
    super.dispose();
  }
}