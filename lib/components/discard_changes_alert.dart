import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/constants.dart';

Future<bool> showDiscardChangesAlert({BuildContext context}) {
  return showDialog(
    context: context,
    child: Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(
              "Are you sure you want to discard changes?",
              style: TextStyle(fontFamily: 'FuturaPT'),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("No",
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
                      color: Color(kGenchiGreen),
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
              "Are you sure you want to discard changes?",
              style: TextStyle(fontFamily: 'FuturaPT'),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text("No",
                              style: TextStyle(
                                  fontFamily: 'FuturaPT',
                                  color: Color(kGenchiOrange),
                                  fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(false);

                          },
                        ),
                        SimpleDialogOption(
                          child: Text("Yes",
                              style: TextStyle(
                                  fontFamily: 'FuturaPT',
                                  color: Color(kGenchiGreen),
                                  fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(true);

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
