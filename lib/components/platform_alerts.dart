import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
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

Future<bool> showYesNoAlert(
    {@required BuildContext context, @required String title, String body}) {
  return showDialog(
    context: context,
    child: Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(
              title,
              style: TextStyle(fontFamily: 'FuturaPT',fontWeight: FontWeight.w500),
            ),
             content: body!=null ? Text(
                body,
                style: TextStyle(fontFamily: 'FuturaPT', fontSize: 18)):null,
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
              title,
              style: TextStyle(fontFamily: 'FuturaPT'),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (body != null)
                      Text(body,
                          style:
                              TextStyle(fontFamily: 'FuturaPT', fontSize: 18)),
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
                            Navigator.of(context, rootNavigator: true)
                                .pop(false);
                          },
                        ),
                        SimpleDialogOption(
                          child: Text("Yes",
                              style: TextStyle(
                                  fontFamily: 'FuturaPT',
                                  color: Color(kGenchiGreen),
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
