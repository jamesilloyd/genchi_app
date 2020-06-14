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
