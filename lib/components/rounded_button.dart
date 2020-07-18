import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {

  const RoundedButton( {this.buttonColor, this.buttonTitle, @required this.onPressed, this.fontColor = Colors.white, this.elevation = false});

  final Color buttonColor;
  final String buttonTitle;
  final Function onPressed;
  final Color fontColor;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      height: 42.0,
      width: 200.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: buttonColor,
        boxShadow: elevation ? [BoxShadow(color: Colors.grey, spreadRadius: 1,blurRadius: 1,offset: Offset(0,1))] : [BoxShadow(color: Colors.transparent)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FlatButton(
          onPressed: onPressed,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              buttonTitle,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: fontColor,
                fontSize: 18.0
              ),
            ),
          ),
        ),
      ),
    );
  }
}
