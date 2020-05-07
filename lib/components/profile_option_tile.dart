import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class ProfileOptionTile extends StatelessWidget {
  final String text;
  final Function onPressed;

  const ProfileOptionTile({this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 50,
          child: FlatButton(
            onPressed: onPressed,
            child: Align(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                    fontWeight: FontWeight.w400,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }
}