import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/services/time_formatting.dart';

class TaskDetailsSection extends StatelessWidget {
  final Task task;
  final Function linkOpen;

  TaskDetailsSection({this.task, this.linkOpen});

  List<Widget> _otherChipBuilder({@required List tags}) {
    List<Widget> widgets = [];
    for (String tag in tags) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
                color: Color(kGenchiLightGreen),
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              child: Text(
                tag,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  String _universities(){

    String unis = "";
    int count = 0;


    for(String uni in task.universities){
      if(count == 0) {
        unis += uni;
      } else if(count == task.universities.length){
        unis += 'and $uni';

      }else{
        unis += ', $uni';
      }
      count ++;
    }

    return unis;

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For Students At',
          style: kTitleTextStyle,
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        Text(_universities(),
        style: kBodyTextStyle),
        SizedBox(
          height: 10,
        ),
        Text(
          'Application Deadline',
          style: kTitleTextStyle,
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        Text(
          task.hasFixedDeadline && task.applicationDeadline != null
              ? getApplicationDeadline(time: task.applicationDeadline)
              : 'OPEN',
          style: task.hasFixedDeadline && task.applicationDeadline != null
              ? kBodyTextStyle
              : TextStyle(fontSize: 20, color: Color(kGenchiOrange)),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Text("Details",
              textAlign: TextAlign.left, style: kTitleTextStyle),
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
          child:
              Text("Tags", textAlign: TextAlign.left, style: kTitleTextStyle),
        ),
        Divider(
          thickness: 1,
          height: 8,
        ),
        Wrap(
          alignment: WrapAlignment.start,
          children: _otherChipBuilder(tags: task.tags),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
