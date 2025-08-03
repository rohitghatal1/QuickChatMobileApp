import 'dart:math';
import "package:flutter/material.dart";

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
  return Scaffold();
  }
}
