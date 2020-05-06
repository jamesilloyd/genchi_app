import 'package:flutter/material.dart';

const kSendButtonTextStyle = TextStyle(
  color: Color(kGenchiOrange),
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
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
