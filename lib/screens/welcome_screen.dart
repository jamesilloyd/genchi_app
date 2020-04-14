import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/login_screen.dart';
import 'package:genchi_app/screens/registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/locator.dart';

class WelcomeScreen extends StatefulWidget {
  //Static makes the string associated with the class, so you don't need to make a new object when calling id
  static const String id = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

//with single... allows the class to act as a ticker for a single animation
class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation animation;
  final _auth = FirebaseAuth.instance;

  final AuthenticationService _authenticationService = locator<AuthenticationService>();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener( () {
      setState(() {});
    },
    );

    //ToDo: ideally want to do this in Main.dart to determine initialRoute
    //Even tho not attached to provider, this does update current User!
    _authenticationService.isUserLoggedIn();
    isUserAlreadyLoggedIn();
  }

  //Automatic login
  //ToDo: move this into main.dart
  void isUserAlreadyLoggedIn() async {
    try {
      final user = await _auth.currentUser();
      if(user != null){
        print("User logged in");
        Navigator.pushReplacementNamed(context, HomeScreen.id);
      } else {
        print("No logged in user");
      }
    } catch (e) {
      print("isUserAlreadyLoggedIn $e");
    }
  }

  @override
  void dispose() {
    //removes the controller after the screen disappears
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/Logo_Clear.png'),
                    height: 60.0,
                  ),
                ),
                Container(
                  width: 20.0,
                ),
                Text(
                  'GENCHI',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
                buttonColor: Colors.lightBlueAccent,
                buttonTitle: 'Log In',
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                }),
            RoundedButton(
              buttonColor: Colors.blueAccent,
              buttonTitle: "Register",
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
