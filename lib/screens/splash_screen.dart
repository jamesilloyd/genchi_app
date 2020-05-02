import 'package:flutter/material.dart';
import 'package:genchi_app/models/authentication.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

//ToDo: Could use this to naviagate to the correct route on start up, would need to jazz it up tho
//ToDo: work out how to do smoother login sequence, have a feeling this page will be used (can't wait on condition to choose route, navigation has to be inside the screen widget)

class SplashScreen extends StatefulWidget {

  static const String id = "splash_screen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool userLoggedIn;


  @override
  void initState() {
    super.initState();
//    userLoggedIn = _authenticationService.isUserLoggedIn();
//    userLoggedIn ? Navigator.pushReplacementNamed(context, HomeScreen.id) : Navigator.pushReplacementNamed(context, WelcomeScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
    );
  }
}
