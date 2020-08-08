import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genchi_app/constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:intl/intl.dart';


class MessageListItem extends StatelessWidget {
  final ImageProvider image;
  final String name;
  final String lastMessage;
  final Timestamp time;
  final bool hasUnreadMessage;
  final Function onTap;
  final String service;
  final Function hideChat;
  final String deleteMessage;
  final String type;

  const MessageListItem(
      {Key key,
      @required this.image,
      @required this.hideChat,
      @required this.name,
      @required this.lastMessage,
      @required this.time,
      @required this.hasUnreadMessage,
      @required this.onTap,
      @required this.type,
      @required this.service,
      this.deleteMessage = 'Archive'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 30,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: 'FuturaPT',
                          fontWeight: hasUnreadMessage
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                  leading: image == null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xffC4C4C4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              Icons.person,
                              color: Color(0xff585858),
                              size: 35,
                            ),
                          ),
                        )
                      :
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(kGenchiCream),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image(
                      image: image,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),

                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(children: [
                          TextSpan(
                            text: '$type - ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'FuturaPT',
                            ),
                          ),
                          TextSpan(
                            text: service,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'FuturaPT',
                              color: Color(kGenchiOrange),
                            ),
                          ),
                        ]),
                      ),
                      hasUnreadMessage
                          ? Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                color: Color(kGenchiOrange),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            )
                          : SizedBox(height: 15.0),
                      SizedBox(height: 6),
                      Text(
                        getSummaryTime(time: time),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: onTap,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(
              height: 0,
              thickness: 1,
            ),
          ),
        ],
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: deleteMessage,
          color: Colors.red[900],
          icon: Icons.delete,
          onTap: hideChat,
        ),
      ],
    );
  }
}
