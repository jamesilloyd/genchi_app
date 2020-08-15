import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/screens/login_screen.dart';
import 'package:genchi_app/screens/onboarding_screen.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';


class WelcomeScreen extends StatefulWidget {
  //Static makes the string associated with the class, so you don't need to make a new object when calling id
  static const String id = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation animation;


  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    animation = ColorTween(begin: Color(kGenchiBlue), end: Color(kGenchiGreen))
        .animate(controller);
    controller.forward();
    controller.addListener(
      () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    ///removes the controller after the screen disappears
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(kGenchiGreen),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * .25,
            ),
            Container(
              height: MediaQuery.of(context).size.height * .25,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/LogoAndName.png'),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .25,
            ),
            Container(
              height: MediaQuery.of(context).size.height * .25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RoundedButton(
                      buttonColor: Color(kGenchiOrange),
                      buttonTitle: 'Log In',
                      onPressed: () {
//                        Navigator.pushNamed(context, RegSequenceScreen.id);
                        Navigator.pushNamed(context, LoginScreen.id);
                      },),
                  RoundedButton(
                    buttonColor: Color(kGenchiBlue),
                    buttonTitle: "Register",
                    onPressed: () {
                      Navigator.pushNamed(context, OnboardingScreen.id);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
