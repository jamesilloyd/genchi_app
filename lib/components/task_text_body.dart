import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/task.dart';


class TaskDetailsSection extends StatelessWidget {

  Task task;
  Function linkOpen;

  TaskDetailsSection({this.task, this.linkOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: kTitleTextStyle),
        Divider(
          thickness: 1,
          height: 8,
        ),
        Text(
          task.service.toUpperCase(),
          style: TextStyle(fontSize: 20, color: Color(kGenchiOrange)),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child:
          Text("Details", textAlign: TextAlign.left, style: kTitleTextStyle),
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        SelectableLinkify(
          text: task.details ?? "",
          onOpen: linkOpen,
          options: LinkifyOptions(humanize: false),
          style: kBodyTextStyle,
        ),
        SizedBox(height: 10),
        Container(
          child: Text("Job Timings",
              textAlign: TextAlign.left, style: kTitleTextStyle),
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        SelectableLinkify(
          text: task.date ?? "",
          onOpen: linkOpen,
          options: LinkifyOptions(humanize: false),
          style: kBodyTextStyle,
        ),
        SizedBox(height: 10),
        Container(
          child: Text("Incentive",
              textAlign: TextAlign.left, style: kTitleTextStyle),
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        SelectableLinkify(
          text: task.price ?? "",
          onOpen: linkOpen,
          options: LinkifyOptions(humanize: false),
          style: kBodyTextStyle,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}