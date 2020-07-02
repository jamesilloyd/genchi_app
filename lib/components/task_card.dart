import 'package:flutter/material.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:genchi_app/constants.dart';

Widget TaskCard(
    {@required Task task,
    @required ImageProvider image,
    @required Function onTap,
      bool isDisplayTask = true,
    bool hasUnreadMessage = false}) {
  return Column(
    children: <Widget>[
      ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: image,
          backgroundColor: Color(kGenchiCream),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          task.details,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if(!isDisplayTask) hasUnreadMessage
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
            Text(
              task.service,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'Posted ${getSummaryTime(time: task.time)}',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      Divider(
        endIndent: 12.0,
        indent: 12.0,
        height: 0,
        thickness: 1,
      )
    ],
  );
}
