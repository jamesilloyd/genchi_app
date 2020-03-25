import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SecondSearchScreen extends StatefulWidget {
  static const String id = "second_search_screen";

  @override
  _SecondSearchScreenState createState() => _SecondSearchScreenState();
}

class _SecondSearchScreenState extends State<SecondSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
        child: Center(
          child: Text("Search Screen 2"),
        ),
      );
    });
  }
}
