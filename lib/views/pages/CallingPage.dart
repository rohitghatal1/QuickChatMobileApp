import 'dart:math';
import "package:flutter/material.dart";
import 'package:quick_chat/config/CallCosntants.dart';
// import 'package:zego_uiki/zego_uiki.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class Callingpage extends StatefulWidget {
  const Callingpage({super.key, required this.callId});

  final String callId;

  @override
  State<Callingpage> createState() => _CallingpageState();
}

class _CallingpageState extends State<Callingpage> {

  final userId = Random().nextInt(10000);
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: AppInfo.appId, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: AppInfo.appSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: 'user_id',
      userName: 'user_name$userId',
      callID: widget.callId,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
