import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class EditAccountField extends StatelessWidget {

  const EditAccountField(
      {@required this.field,
        this.initialValue,
        @required this.onChanged,
        this.isEditable = true});

  final String field;
  final String initialValue;
  final Function onChanged;
  final bool isEditable;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 30.0,
        ),
        Text(
          field,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Color(kGenchiBlue),
          ),
        ),
        SizedBox(
            height: 5.0
        ),
        TextField(
          style: TextStyle(
            color: isEditable ? Colors.black : Colors.grey,
            fontSize: 18.0,
          ),
          textAlign: TextAlign.left,
          onChanged: onChanged,
          readOnly: isEditable ? false : true,
          controller: TextEditingController()..text = initialValue,
          decoration: kTextFieldDecoration,
          cursorColor: Color(kGenchiOrange),
        ),
      ],
    );
  }
}
