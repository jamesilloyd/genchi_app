import 'package:flutter/material.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:genchi_app/constants.dart';


class TaskCard extends StatelessWidget {

  final Task task;
  final bool orangeBackground;
  final String imageURL;
  final Function onTap;
  final bool isDisplayTask;
  final bool hasUnreadMessage;

  const TaskCard(
      {Key key,
        @required this.task,
        this.orangeBackground = false,
        @required this.imageURL,
        @required this.onTap,
        this.isDisplayTask = true,
        this.hasUnreadMessage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
          onTap: onTap,
          leading: ListDisplayPicture(
            imageUrl: imageURL,
            height: 56,
          ),
          title: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 20,
                fontWeight: hasUnreadMessage ? FontWeight.w500 : FontWeight.w400),
          ),
          subtitle: Text(
            task.details,
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
                  color: Color(
                      orangeBackground ? kGenchiGreen : kGenchiOrange),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
              )
                  : SizedBox(height: 15.0),
              Text(
                getSummaryTime(time: task.time),
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 15),
              ),
              Text(
                task.service,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 15,
                    color: Color(orangeBackground ? kGenchiGreen : kGenchiOrange),
                    fontWeight: FontWeight.w500),
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
}


