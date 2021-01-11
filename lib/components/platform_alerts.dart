import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/constants.dart';

Future<void> showAlertIOS(
    {BuildContext context, VoidCallback actionFunction, String alertMessage}) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context, 'Cancel');
        },
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(
            alertMessage,
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
          onPressed: actionFunction,
        )
      ],
    ),
  );
}

Future<void> showAlertAndroid(
    {BuildContext context, VoidCallback actionFunction, String alertMessage}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'Are you sure you want to ${alertMessage.toLowerCase()}?',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.black54),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(
              alertMessage.toUpperCase(),
              style: TextStyle(color: Colors.red),
            ),
            onPressed: actionFunction,
          ),
        ],
      );
    },
  );
}

Future showDialogBox(
    {@required BuildContext context, @required String title, String body}) {
  return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
            backgroundColor: Color(kGenchiCream),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(9))),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'FuturaPT', fontSize: 16),
            ),
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        if (body != null)
                          Text(body,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'FuturaPT', fontSize: 16)),
                      ]))
            ]);
      });
}

Future<bool> showYesNoAlert(
    {@required BuildContext context, @required String title, String body}) {
  return showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        backgroundColor: Color(kGenchiCream),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9))),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'FuturaPT', fontSize: 16),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (body != null)
                  Text(body,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'FuturaPT', fontSize: 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SimpleDialogOption(
                        child: Text("No",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'FuturaPT',
                                color: Color(kGenchiOrange),
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop(false);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SimpleDialogOption(
                        child: Text("Yes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'FuturaPT',
                                fontSize: 18,
                                color: Color(kGenchiGreen),
                                fontWeight: FontWeight.w500)),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop(true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
