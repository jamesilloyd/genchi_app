import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';

class SecondSearchScreen extends StatefulWidget {
  static const String id = "Settings1";

  @override
  _SecondSearchScreenState createState() => _SecondSearchScreenState();
}

class _SecondSearchScreenState extends State<SecondSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Search 2"),
      body: Center(
        child: Text(
          "Search screen 2",
          style: TextStyle(
            fontSize: 30.0,
          )
        ),
      ),
    );
  }
}
