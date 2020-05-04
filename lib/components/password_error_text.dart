import 'package:flutter/material.dart';

class PasswordErrorText extends StatelessWidget {

  PasswordErrorText({this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Center(
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}