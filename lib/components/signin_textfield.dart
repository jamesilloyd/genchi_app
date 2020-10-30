import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';
import 'dart:io' show Platform;

class SignInTextField extends StatelessWidget {
  const SignInTextField(
      {@required this.onChanged,
      @required this.hintText,
      this.isPasswordField = false,
      this.isNameField = false,
      @required this.field});

  final Function onChanged;
  final String hintText;
  final bool isPasswordField;
  final bool isNameField;
  final String field;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          field,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          width: 250,
          child: TextField(
              keyboardType:
                  isNameField ? TextInputType.text : TextInputType.emailAddress,
              obscureText: isPasswordField,
              obscuringCharacter: Platform.isIOS ? "" : '■',
              textCapitalization: isNameField
                  ? TextCapitalization.words
                  : TextCapitalization.none,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
              cursorColor: Color(kGenchiOrange),
              onChanged: onChanged,
              autocorrect: isNameField,
              decoration:
                  kSignInTextFieldDecoration.copyWith(hintText: hintText)),
        ),
      ],
    );
  }
}
