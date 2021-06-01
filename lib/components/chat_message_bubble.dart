import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe, this.time});

  final String sender;
  final String text;
  final bool isMe;
  final Timestamp time;


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Padding(
        padding: isMe
            ? EdgeInsets.only(top: 4.0, bottom: 4.0)
            : EdgeInsets.only(top: 4.0, bottom: 4.0),
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
                        SelectableLinkify(
                          text: text,
                          onOpen: _onOpenLink,
                          cursorColor: Color(kGenchiOrange),
                          options: LinkifyOptions(humanize: false),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                Text(
                  getMessageBubbleTime(time: time),
                  textAlign: isMe ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                )
              ],
            ),
        ),
      ],
    );
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    if (link.runtimeType == EmailElement) {
      launch('mailto:${link.text}?subject=Genchi');
    } else {
      String url = link.url;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $link';
      }
    }
  }

}
