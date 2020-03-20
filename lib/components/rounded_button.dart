import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton( {this.buttonColor, this.buttonTitle, @required this.onPressed});

  final Color buttonColor;
  final String buttonTitle;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
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