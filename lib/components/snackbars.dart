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

const kNewUniversitySnackbar = SnackBar(
  backgroundColor: Color(kGenchiLightOrange),
  duration: Duration(seconds: 5),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'Thanks!\nWe will do our best to bring Genchi to you soon!',
    style: TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);

const kSubmitRequestSnackbar = SnackBar(
  backgroundColor: Color(kGenchiLightOrange),
  duration: Duration(seconds: 3),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'Thanks for your feedback, we will get on it!',
    style: TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
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

const kDeepLinkCreated = SnackBar(
  backgroundColor: Color(kGenchiLightGreen),
  duration: Duration(seconds: 7),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'A link has been copied to your clipboard. Paste to share 😊',
    style: TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);

const kApplicationLinkNotWorking = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 5),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'Sorry, it appears this link is not working. We will fix ASAP',
    style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);

const kNoApplicantsSelected = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 5),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'You have not selected any applicants!',
    style: TextStyle(
        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);
