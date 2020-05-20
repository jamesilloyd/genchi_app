import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe, this.time});

  final String sender;
  final String text;
  final bool isMe;
  final Timestamp time;

  String getTime() {


    if(time.toDate().weekday == DateTime.now().weekday) {

      var formatter = new DateFormat.Hm();
      String formatted = formatter.format(time.toDate());

      return formatted;

    } else if(time.toDate().difference(DateTime.now()).inDays < 7) {
      var formatter = new DateFormat.E().add_Hm();
      String formatted = formatter.format(time.toDate());
      return formatted;

    } else {
      var formatter = new DateFormat.MMMMd().add_Hm();
      String formatted = formatter.format(time.toDate());
      return formatted;
    }
  }

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
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
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
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(kGenchiCream),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  getTime(),
                  textAlign: isMe ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                    fontSize: 12,
                  ),
                )
              ],
            ),
        ),
      ],
    );
  }
}
