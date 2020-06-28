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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Color(kGenchiLightOrange),
        boxShadow: [ BoxShadow(
          color: Colors.grey,
          offset: Offset(0.0, 1.0), //(x,y)
          blurRadius: 1.0,
        ),]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: FlatButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      buttonTitle,
                      style: TextStyle(
                        color: Color(kGenchiBlue),
                        fontSize: 16.0,
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
      ),
    );
  }
}
