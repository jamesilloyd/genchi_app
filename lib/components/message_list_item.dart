import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genchi_app/constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageListItem extends StatelessWidget {

  final AssetImage image;
  final String name;
  final String lastMessage;
  final Timestamp time;
  final bool hasUnreadMessage;
  final Function onTap;
  final String service;

  const MessageListItem({
    Key key,
    this.image,
    this.name,
    this.lastMessage,
    this.time,
    this.hasUnreadMessage,
    this.onTap,
    this.service,
  }) : super(key: key);


  String getTime() {


    if(time.toDate().weekday == DateTime.now().weekday) {

      var formatter = new DateFormat.Hm();
      String formatted = formatter.format(time.toDate());

      return formatted;

    } else if(time.toDate().difference(DateTime.now()).inDays > 7) {
      var formatter = new DateFormat.E();
      String formatted = formatter.format(time.toDate());
      return formatted;

    } else {
      var formatter = new DateFormat.MMMMd();
      String formatted = formatter.format(time.toDate());
      return formatted;
    }
  }



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
                  title: Text(
                    "$name - $service",
                    style: TextStyle(
                        fontSize: 20,
                      fontWeight: hasUnreadMessage ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                  leading: CircleAvatar(
                    backgroundImage: image,
                    backgroundColor: Color(kGenchiCream),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      hasUnreadMessage
                          ? Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            color: Color(kGenchiOrange),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),),
                      )
                          : SizedBox(height: 15.0),
                      SizedBox(height:6),
                      Text(
                        getTime(),
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
          ),
        ],
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Archive',
          color: Colors.red[900],
          icon: Icons.archive,
          onTap: () {},
        ),
      ],
    );
  }
}