import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/task.dart';


class TaskDetailsSection extends StatelessWidget {
  TextStyle titleTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );
  Task task;
  Function linkOpen;

  TaskDetailsSection({this.task, this.linkOpen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: titleTextStyle),
        Divider(
          thickness: 1,
          height: 8,
        ),
        Text(
          task.service.toUpperCase(),
          style: TextStyle(fontSize: 22, color: Color(kGenchiOrange)),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child:
          Text("Details", textAlign: TextAlign.left, style: titleTextStyle),
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        SelectableLinkify(
          text: task.details ?? "",
          onOpen: linkOpen,
          options: LinkifyOptions(humanize: false),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 10),
        Container(
          child: Text("Job Timings",
              textAlign: TextAlign.left, style: titleTextStyle),
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        SelectableLinkify(
          text: task.date ?? "",
          onOpen: linkOpen,
          options: LinkifyOptions(humanize: false),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 10),
        Container(
          child: Text("Incentive",
              textAlign: TextAlign.left, style: titleTextStyle),
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        SelectableText(
          task.price ?? "",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}