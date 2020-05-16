import 'package:flutter/material.dart';

const kForgotPasswordSnackbar = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 3),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'Check your email for a password reset link',
    style: TextStyle(
        color: Color(kGenchiCream), fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);

const kProviderDoesNotExistSnackBar = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 3),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'Provider No Longer Exists',
    style: TextStyle(
        color: Color(kGenchiCream), fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type here',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Color(kGenchiOrange), width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: "",
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  fillColor: Color(kGenchiCream),
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(kGenchiCream), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(kGenchiCream), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kGenchiOrange = 0xfff19300;
const kGenchiBlue = 0xff05004e;
const kGenchiCream = 0xfff9f8eb;
const kGenchiGreen = 0xff76b39d;

//ToDo: start implementing print statements depending on this value e.g. if(debugMode) print("Home screen - ${}");
const debugMode = false;

const GenchiURL = 'https://www.genchi.app';
const GenchiAboutURL = 'https://www.genchi.app/about-us';
