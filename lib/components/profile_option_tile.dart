import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class ProfileOptionTile extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool isPressable;

  const ProfileOptionTile({this.text, @required this.onPressed,this.isPressable = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 50,
            child: isPressable ? FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: onPressed,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,0,0,5),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ): Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,5),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}