import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/components/log_out_alerts_platform.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';

FirebaseUser loggedInUser;

class SecondProfileScreen extends StatefulWidget {
  static const String id = "second_profile_screen";

  @override
  _SecondProfileScreenState createState() => _SecondProfileScreenState();
}

class _SecondProfileScreenState extends State<SecondProfileScreen> {
  final _auth = FirebaseAuth.instance;
  String userEmail;

  void logOutNavigation() {
    _auth.signOut();
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        WelcomeScreen.id, (Route<dynamic> route) => false);
  }

  void passwordReset() {
    _auth.sendPasswordResetEmail(email: userEmail);
    //ToDo: add in "check your email" message and potential log out
    Navigator.of(context).pop();
//    _auth.confirmPasswordReset(oobCode, newPassword)
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<FirebaseCRUDModel>(context);
    final authProvider = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: AppNavigationBar(barTitle: "Settings"),
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
                  //Update details
                  profileProvider.updateUser(
                    User(
                        name: "James 7",
                        email: authProvider.currentUser.email,
                        id: authProvider.currentUser.id,
                        bio: authProvider.currentUser.bio,
                        profilePicture: authProvider.currentUser.profilePicture,
                        timeStamp: authProvider.currentUser.timeStamp),
                  );
                  //Need to repopulate current user data
                  authProvider.updateCurrentUserData();
//                  Provider.of<Profile>(context, listen: false).changeName("123 Lloyd");
                },
              ),
              RoundedButton(
                buttonColor: Colors.greenAccent,
                buttonTitle: "Change password",
                onPressed: () {
                  //ToDo: have a look at this, alert not popping afterwards
                  Platform.isIOS
                      ? showAlertIOS(context, passwordReset, "Reset password")
                      : showAlertAndroid(
                          context, passwordReset, "Reset password");
                },
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
                  Platform.isIOS
                      ? showAlertIOS(context, logOutNavigation, "Log out")
                      : showAlertAndroid(context, logOutNavigation, "Log out");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
