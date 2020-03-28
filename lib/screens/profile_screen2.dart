import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';

class SecondProfileScreen extends StatefulWidget {
  static const String id = "second_profile_screen";

  @override
  _SecondProfileScreenState createState() => _SecondProfileScreenState();
}

class _SecondProfileScreenState extends State<SecondProfileScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              //Implement logout functionality
              _auth.signOut();
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(WelcomeScreen.id, (Route<dynamic> route) => false);
            },
          ),
        ],
        title: Text(
          "Profile Settings",
          style: TextStyle(fontSize: 30),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.white,
    );
  }
}
