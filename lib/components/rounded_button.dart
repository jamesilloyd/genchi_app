import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton( {this.buttonColor, this.buttonTitle, @required this.onPressed});

  final Color buttonColor;
  final String buttonTitle;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      height: 42.0,
      width: 200.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: buttonColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FlatButton(
          onPressed: onPressed,
          child: Text(
            buttonTitle,
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}
