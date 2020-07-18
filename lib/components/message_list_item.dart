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
  final bool isHiring;

  const MessageListItem(
      {Key key,
      this.image,
      @required this.hideChat,
      this.name,
      this.lastMessage,
      this.time,
      this.hasUnreadMessage,
      @required this.onTap,
        this.isHiring,
      this.service,
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
                flex: 10,
                child: ListTile(
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
                      ) ,

//
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
                      : CircleAvatar(
                          backgroundImage: image,
                          radius: 30,
                          backgroundColor: Color(kGenchiCream),
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
                            text: service,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'FuturaPT',
                              color: Color(kGenchiOrange),
                            ),
                          ),
                          TextSpan(
                            text:isHiring ? ' - HIRING' : ' - PROVIDING',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'FuturaPT',
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
          Divider(
            endIndent: 12.0,
            indent: 12.0,
            height: 0,
            thickness: 1,
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
