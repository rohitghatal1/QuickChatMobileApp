import 'package:jiffy/jiffy.dart';

String servertoLocalTime(String serverDate) {
  DateTime serverTime = DateTime.parse(serverDate);
  DateTime localTime = serverTime.toLocal();

  String formattedDate =
  Jiffy.parse(localTime.toString()).format(pattern: "yyyy-MM-dd hh:mm a");

  return formattedDate;
}