import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe, this.time = ""});

  final String sender;
  final String text;
  final bool isMe;
  final String time;
//  final String timeStamp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Padding(
        padding: isMe
            ? EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0)
            : EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
            child: ClipRRect(
              borderRadius: isMe? BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)):
              BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)),
              child: Container(
                constraints: BoxConstraints(maxWidth: 300.0),
                padding: EdgeInsets.all(8.0),
                color: isMe ? Color(kGenchiGreen) : Colors.grey,
                child: Stack(
                  children: <Widget>[
                    Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(kGenchiCream),
                      ),
                    ),
                    isMe
                        ? Positioned(
                            bottom: 1,
                            left: 10,
                            child: Text(
                              time,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w500),
                            ),
                          )
                        : Positioned(
                            bottom: 1,
                            right: 10,
                            child: Text(
                              time,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w500),
                            ),
                          )
                  ],
                ),
              ),
            ),
        ),
      ],
    );
  }
}
