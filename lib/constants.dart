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
    topLeft: Radius.circular(20.0),
    topRight: Radius.circular(20.0),
  ),
);

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

Map<int, Color> orangeColor = {
  50: Color.fromRGBO(241, 147, 0, .1),
  100: Color.fromRGBO(241, 147, 0, .2),
  200: Color.fromRGBO(241, 147, 0, .3),
  300: Color.fromRGBO(241, 147, 0, .4),
  400: Color.fromRGBO(241, 147, 0, .5),
  500: Color.fromRGBO(241, 147, 0, .6),
  600: Color.fromRGBO(241, 147, 0, .7),
  700: Color.fromRGBO(241, 147, 0, .8),
  800: Color.fromRGBO(241, 147, 0, .9),
  900: Color.fromRGBO(241, 147, 0, 1),
};


Map<int, Color> greenColor = {
  50: Color.fromRGBO(118, 179, 157, .1),
  100: Color.fromRGBO(118, 179, 157, .2),
  200: Color.fromRGBO(118, 179, 157, .3),
  300: Color.fromRGBO(118, 179, 157, .4),
  400: Color.fromRGBO(118, 179, 157, .5),
  500: Color.fromRGBO(118, 179, 157, .6),
  600: Color.fromRGBO(118, 179, 157, .7),
  700: Color.fromRGBO(118, 179, 157, .8),
  800: Color.fromRGBO(118, 179, 157, .9),
  900: Color.fromRGBO(118, 179, 157, 1),
};

MaterialColor kMaterialGenchiOrange = MaterialColor(kGenchiOrange, orangeColor);
MaterialColor kMaterialGenchiGreen = MaterialColor(kGenchiGreen, greenColor);

const kGenchiLightOrange = 0xffF7BE66;
const kGenchiBrown = 0xffD3CCAF;
const kGenchiLightBlue = 0xff534F8E;

const kRed = 0xffDA2222;
const kGreen = 0xff41820E;
const kPurple = 0xff5415BA;

const debugMode = true;

TextStyle kTitleTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w500,
);

TextStyle kBodyTextStyle = TextStyle(

    fontSize: 18,
    fontWeight: FontWeight.w400
);


const GenchiPlayStoreURL = 'https://play.google.com/store/apps/details?id=app.genchi.genchi';
const GenchiAppStoreURL = 'https://apps.apple.com/us/app/genchi/id1473696183';
const GenchiURL = 'https://www.genchi.app';
const GenchiAboutURL = 'https://www.genchi.app/about-us';
const GenchiFAQsURL = 'https://www.genchi.app/faqs';
const GenchiTACsURL = 'https://www.genchi.app/termsconditions';
const GenchiPPURL = 'https://www.genchi.app/privacy-policy';
const GenchiHirerURL = 'https://www.genchi.app/hirer';
const GenchiProviderURL = 'https://www.genchi.app/provider';
const GenchiFacebookURL = 'https://www.facebook.com/genchiapp/';
const GenchiFeedbackURL = 'https://forms.gle/C3auGkD693xRVaXD9';
