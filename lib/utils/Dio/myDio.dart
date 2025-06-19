import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MyDio {
  Future<Dio> getDio() async {
    String apiUrl = "http://103.250.132.138:8885/api";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = await prefs.getString("quickChatAccessToken");

    BaseOptions baseOptions = BaseOptions(
        baseUrl: "${apiUrl}",
        connectTimeout: Duration(seconds: 20),
        receiveTimeout: Duration(seconds: 20),
        headers: {"Authorization": "Bearer ${accessToken}"});

    Dio dio = Dio(baseOptions);
    return dio;
  }
}
