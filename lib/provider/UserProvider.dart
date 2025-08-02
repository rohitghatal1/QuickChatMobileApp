import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserProvider extends ChangeNotifier {
  Map<dynamic, dynamic> userData = {};

  getConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await (await MyDio().getDio()).get("/users/auth/me");

      var userDataBox = await Hive.openBox("userData");
      await userDataBox.clear();

      // Extract the list of users from response
      Map<dynamic, dynamic> dataList = response.data;

      if (dataList.isNotEmpty) {
        // Save the first user (or whole list depending on requirement)
        await userDataBox.add(dataList);
      }
    } on DioException catch (e) {
      print(e.response);
    }

    var userDataBox = await Hive.openBox("userData");
    List<dynamic> hiveMapData = userDataBox.values.toList();

    if (hiveMapData.isNotEmpty) {
      userData = hiveMapData[0];
      debugPrint("userData from hive $userData");
      notifyListeners();
    } else {
      debugPrint("No user data found in Hive.");
    }
}}