import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

SnackBar TextSnackBar({String text}) {
  return SnackBar(
    backgroundColor: Color(kGenchiOrange),
    duration: Duration(seconds: 3),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
    content: Text(
      text,
      style: TextStyle(
          color: Color(kGenchiCream),
          fontSize: 15,
          fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
    ),
  );
}


const kForgotPasswordSnackbar = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 5),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'Check your email for a password reset link',
    style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);


const kDevelopmentFeature = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 5),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'Thanks for showing your interest, we are testing the demand for this feature!',
    style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);
