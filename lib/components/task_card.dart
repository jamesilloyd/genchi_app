import 'package:flutter/material.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:genchi_app/constants.dart';

///
Widget TaskCard(
    {@required Task task,
    @required ImageProvider image,
    @required Function onTap,
    @required String hirerType,
    bool isDisplayTask = true,
    bool hasUnreadMessage = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        onTap: onTap,
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
            : Container(
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
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        subtitle: Text(
          "Posted ${getSummaryTime(time: task.time)}: ${task.details}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
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
            Text(
              hirerType,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 15),
            ),
            Text(
              task.service,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 15, color: Color(kGenchiOrange)),
            ),
          ],
        ),
      ),
      Divider(
        height: 0,
        thickness: 1,
      )
    ],
  );
}
