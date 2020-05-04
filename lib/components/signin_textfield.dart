import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';


class SignInTextField extends StatelessWidget {
  const SignInTextField({@required this.onChanged, @required this.hintText, this.isPasswordField = false});

  final Function onChanged;
  final String hintText;
  final bool isPasswordField;

  @override
  Widget build(BuildContext context) {
    return TextField(
        keyboardType: isPasswordField ? TextInputType.text: TextInputType.emailAddress,
        obscureText: isPasswordField,
        textAlign: TextAlign.left,
        cursorColor: Color(kGenchiOrange),
        onChanged: onChanged,
        decoration: kTextFieldDecoration.copyWith(hintText: hintText));
  }
}