import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/constants.dart';

Future<bool> showHirerAlert({BuildContext context}) {
  return showDialog(
    context: context,
    child: Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(
              "Create Hirer Account",
              style: TextStyle(fontFamily: 'FuturaPT'),
            ),
            content: Text(
                "Are you ready to hire students with skills in the Cambridge community?",
                style: TextStyle(fontFamily: 'FuturaPT', fontSize: 18)),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Not now",
                    style: TextStyle(
                        fontFamily: 'FuturaPT',
                        color: Color(kGenchiOrange),
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  "Yes",
                  style: TextStyle(
                      fontFamily: 'FuturaPT',
                      color: Color(kGenchiBlue),
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
              ),
            ],
          )
        : SimpleDialog(
            title: Text(
              "Create Hirer Account",
              style: TextStyle(fontFamily: 'FuturaPT'),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                        "Are you ready to hire students with skills in the Cambridge community?",
                        style: TextStyle(fontFamily: 'FuturaPT', fontSize: 18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text("Not now",
                              style: TextStyle(
                                  fontFamily: 'FuturaPT',
                                  color: Color(kGenchiOrange),
                                  fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop(false);
                          },
                        ),
                        SimpleDialogOption(
                          child: Text("Yes",
                              style: TextStyle(
                                  fontFamily: 'FuturaPT',
                                  color: Color(kGenchiBlue),
                                  fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop(true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}
