import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("Profile"),
            border: Border.all(width:0.0),
          ),
          child: Center(
            child: Text(
              "This is the profile page",
              style: CupertinoTheme.of(context).textTheme.actionTextStyle,
            ),
          ),
        );
      },
    );
  }
}
