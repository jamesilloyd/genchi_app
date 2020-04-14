import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


Future<void> showAlertIOS(BuildContext context, VoidCallback logOutFunction, String alertMessage) {

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
          onPressed: logOutFunction,
        )
      ],
    ),
  );
}


Future<void> showAlertAndroid(BuildContext context, VoidCallback logOutFunction, String alertMessage) {
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
                style: TextStyle(color: Colors.black54),
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
            onPressed: logOutFunction,
          ),
        ],
      );
    },
  );
}
