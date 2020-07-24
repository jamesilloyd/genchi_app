import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class SearchServiceTile extends StatelessWidget {
  const SearchServiceTile(
      {this.buttonTitle,
      @required this.onPressed,
      this.imageAddress,
      this.width});

  final String buttonTitle;
  final Function onPressed;
  final String imageAddress;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: width / 1.6,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Color(kGenchiLightOrange),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0, 2.0), //(x,y)
                blurRadius: 2.0,
                spreadRadius: 1
              ),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: FlatButton(
            onPressed: onPressed,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(1.0, 5, 1, 0),
              child: Stack(
                overflow: Overflow.clip,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonTitle,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height < 600 ? 14:18.0,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 5),
                    child: Container(
                      height: width / 1.6 * 0.85,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(imageAddress),
                              alignment: Alignment.centerRight),
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
