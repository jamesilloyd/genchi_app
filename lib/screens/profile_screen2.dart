import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';
import 'edit_account_screen.dart';

FirebaseUser loggedInUser;

class SecondProfileScreen extends StatefulWidget {
  static const String id = "second_profile_screen";

  @override
  _SecondProfileScreenState createState() => _SecondProfileScreenState();
}

class _SecondProfileScreenState extends State<SecondProfileScreen> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<FirebaseCRUDModel>(context);
    final authProvider = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Settings"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RoundedButton(
                buttonColor: Colors.blueAccent,
                buttonTitle: "Change details",
                onPressed: () {
                  Navigator.pushNamed(context, EditAccountScreen.id);
                },
              ),
              RoundedButton(
                buttonColor: Colors.deepOrange,
                buttonTitle: "Create provider profile",
                onPressed: () {},
              ),
              RoundedButton(
                buttonColor: Colors.grey,
                buttonTitle: "Log out",
                onPressed: () {
                  Platform.isIOS
                      ? showAlertIOS(context, () {
                          authProvider.signUserOut();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                  (Route<dynamic> route) => false);
                        }, "Log out")
                      : showAlertAndroid(context, () {
                          authProvider.signUserOut();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                  (Route<dynamic> route) => false);
                        }, "Log out");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
