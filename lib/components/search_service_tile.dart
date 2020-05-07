import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class SearchServiceTile extends StatelessWidget {
  const SearchServiceTile(
      {this.buttonTitle, @required this.onPressed, this.icon});

  final String buttonTitle;
  final Function onPressed;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Color(kGenchiGreen),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: FlatButton(
            onPressed: onPressed,
            child: Column(
              children: <Widget>[
                Align(
                  child: Text(
                    '${buttonTitle}s',
                    style: TextStyle(
                      color: Color(kGenchiCream),
                      fontSize: 25.0,
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    icon,
                    size: 100,
                    color: Color(kGenchiBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
