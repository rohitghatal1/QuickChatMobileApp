import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MyDio {
  Future<Dio> getDio() async {
    String apiUrl = "http://103.250.138.120/api/v1";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = await prefs.getString("accessToken");

    BaseOptions baseOptions = BaseOptions(
        baseUrl: "${apiUrl}",
        connectTimeout: Duration(seconds: 20),
        receiveTimeout: Duration(seconds: 20),
        headers: {"Authorization": "Bearer ${accessToken}"})

    Dio dio = Dio(baseOptions);
    return dio;
  }
}
