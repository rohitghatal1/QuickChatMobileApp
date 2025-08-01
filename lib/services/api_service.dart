import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quick_chat/models/user.dart';

import '../config/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  Future<List<User>> getUsers() async {
    final response = await get('/users/getUsers');
    return (response as List).map((user) => User.fromJson(user)).toList();
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic body, {String? token}) async {
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    print('Raw response body: ${response.body}');
    final responseBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      Fluttertoast.showToast(
          msg: responseBody['message'] ?? 'An error occurred');
      throw Exception(responseBody['message'] ?? 'Failed to load data');
    }
  }
}
