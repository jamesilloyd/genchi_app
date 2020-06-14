import 'package:flutter/material.dart';
import 'package:genchi_app/models/task.dart';


class TaskCard extends StatelessWidget {
  const TaskCard({
    Key key,
    @required this.task,
    @required this.onTap,
  }) : super(key: key);

  final Task task;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: onTap,
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
          trailing: Text(
            task.service,
          ),
        ),
        Divider(
          endIndent: 12.0,
          indent: 12.0,
          height: 0,
        )
      ],
    );
  }
}
