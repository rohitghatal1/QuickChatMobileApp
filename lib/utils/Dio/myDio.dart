import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDio {
  Future<Dio> getDio() async {
    // String apiUrl = "http://103.250.132.138:8885/api";
    String apiUrl = "http://192.168.18.31:5000/api";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = await prefs.getString("quickChatAccessToken");

    print("Access token: $accessToken"); // Debug: Check if token exists

    BaseOptions baseOptions = BaseOptions(
      baseUrl: apiUrl, // Removed unnecessary string interpolation
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json", // Explicitly set content type
      },
    );

    Dio dio = Dio(baseOptions);

    // Add interceptors for better debugging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("Sending request to ${options.uri}");
        print("Headers: ${options.headers}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Received response: ${response.statusCode}");
        print("Data: ${response.data}");
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        print("Dio error: ${e.message}");
        print("Error response: ${e.response?.data}");
        return handler.next(e);
      },
    ));

    return dio;
  }
}