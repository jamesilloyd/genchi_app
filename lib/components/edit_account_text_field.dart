import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class EditAccountField extends StatelessWidget {
  const EditAccountField(
      {@required this.field,
      @required this.onChanged,
      this.isEditable = true,
      @required this.textController,
      this.hintText});

  final String field;
  final Function onChanged;
  final bool isEditable;
  final TextEditingController textController;
  final String hintText;


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
          ),
        ),
        SizedBox(height: 5.0),
        TextField(
          textCapitalization: TextCapitalization.sentences,
          maxLines: null,
          style: TextStyle(
            color: isEditable ? Colors.black : Colors.grey,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.left,
          onChanged: onChanged,
          readOnly: isEditable ? false : true,
          controller: textController,
          decoration: kTextFieldDecoration.copyWith(hintText: hintText),
          cursorColor: Color(kGenchiOrange),
        ),
      ],
    );
  }
}
