import 'package:flutter/material.dart';
import 'package:genchi_app/components/message_handler.dart';

class TestScreen extends StatelessWidget {
  static const id = 'test_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MessageHandler(),
    );
  }
}
