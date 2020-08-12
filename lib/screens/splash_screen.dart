import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(kGenchiCream),
      child: Center(
        child: Image.asset('images/Logo_Clear.png',height: 100,),
      ),
    );
  }
}
//