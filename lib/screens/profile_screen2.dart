import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/components/log_out_alerts_platform.dart';


FirebaseUser loggedInUser;

class SecondProfileScreen extends StatefulWidget {
  static const String id = "second_profile_screen";

  @override
  _SecondProfileScreenState createState() => _SecondProfileScreenState();
}

class _SecondProfileScreenState extends State<SecondProfileScreen> {
  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
        print(loggedInUser.displayName);
      }
    } catch (e) {
      print(e);
    }
  }

  void logOutNavigation() {
    _auth.signOut();
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        WelcomeScreen.id, (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(barTitle: "Profile Settings"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RoundedButton(
                buttonColor: Colors.blueAccent,
                buttonTitle: "Reset name",
                onPressed: () {},
              ),
              RoundedButton(
                buttonColor: Colors.redAccent,
                buttonTitle: "Reset email",
                onPressed: () {},
              ),
              RoundedButton(
                buttonColor: Colors.greenAccent,
                buttonTitle: "Reset password",
                onPressed: () {},
              ),
              RoundedButton(
                buttonColor: Colors.cyanAccent,
                buttonTitle: "Create provider profile",
                onPressed: () {},
              ),
              RoundedButton(
                buttonColor: Colors.grey,
                buttonTitle: "Log out",
                onPressed: () {
                  //ToDo: implement material widget for logout
                  Platform.isIOS ? showLogOutIOS(context,logOutNavigation) : showLogOutAndroid(context, logOutNavigation);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
