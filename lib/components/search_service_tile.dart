import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class SearchServiceTile extends StatelessWidget {
  const SearchServiceTile(
      {this.buttonTitle, @required this.onPressed, this.imageAddress});

  final String buttonTitle;
  final Function onPressed;

  final String imageAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Color(kGenchiGreen),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: FlatButton(
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Text(
                    '${buttonTitle}s',
                    style: TextStyle(
                      color: Color(kGenchiCream),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Image.asset(
                  imageAddress,
                  fit: BoxFit.contain,
                  height: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
