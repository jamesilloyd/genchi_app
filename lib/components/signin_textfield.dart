import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';


class SignInTextField extends StatelessWidget {
  const SignInTextField({@required this.onChanged, @required this.hintText, this.isPasswordField = false, this.isNameField = false, @required this.field});

  final Function onChanged;
  final String hintText;
  final bool isPasswordField;
  final bool isNameField;
  final String field;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(field,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(kGenchiCream)
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
              keyboardType: isPasswordField ? TextInputType.text: TextInputType.emailAddress,
              obscureText: isPasswordField,
              textCapitalization: isNameField ? TextCapitalization.words : TextCapitalization.none,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
              cursorColor: Color(kGenchiOrange),
              onChanged: onChanged,
              decoration: kTextFieldDecoration.copyWith(hintText: hintText)),
        ),
      ],
    );
  }
}