import 'package:flutter/material.dart';

Divider kGenchiBoldDivider() {
  return Divider(
    height: 0,
    thickness: 1,
  );
}

const kCantUploadImageSnackBar = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 3),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'There was an error, please check your internet connection.',
    style: TextStyle(
        color: Color(kGenchiCream), fontSize: 15, fontWeight: FontWeight.w600),
    textAlign: TextAlign.center,
  ),
);

const kBadURLSnackbar = SnackBar(
  backgroundColor: Color(kGenchiOrange),
  duration: Duration(seconds: 3),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
  content: Text(
    'The URL is badly formatted. Start with https://...',
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

const kEditAccountTextFieldDecoration = InputDecoration(
  hintText: "",
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kSignInTextFieldDecoration = InputDecoration(
  hintText: "",
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const modalBottomSheetBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)));

const modalBottomSheetContainerDecoration = BoxDecoration(
  color: Color(kGenchiCream),
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20.0),
    topRight: Radius.circular(20.0),
  ),
);

const kGenchiOrange = 0xfff19300;
const kGenchiBlue = 0xff05004e;
const kGenchiCream = 0xfff9f8eb;
const kGenchiGreen = 0xff76b39d;
const kGenchiLightGreen = 0xffafcac0;

const kGenchiLightOrange = 0xffF7BE66;
const kGenchiBrown = 0xffD3CCAF;
const kGenchiLightBlue = 0xff534F8E;

const debugMode = true;
const bool devMode = true;

const GenchiURL = 'https://www.genchi.app';
const GenchiAboutURL = 'https://www.genchi.app/about-us';
const GenchiFAQsURL = 'https://www.genchi.app/faqs';
const GenchiTACsURL = 'https://www.genchi.app/termsconditions';
const GenchiPPURL = 'https://www.genchi.app/privacy-policy';
const GenchiHirerURL = 'https://www.genchi.app/hirer';
const GenchiProviderURL = 'https://www.genchi.app/provider';
const GenchiFacebookURL = 'https://www.facebook.com/genchiapp/';
const GenchiFeedbackURL = 'https://forms.gle/2Fjdu7uQ4AzcbW8y5';
