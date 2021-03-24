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
                fontWeight:
                    hasUnreadMessage ? FontWeight.w500 : FontWeight.w400),
          ),
          subtitle: Text(
            task.hasFixedDeadline && task.applicationDeadline != null
                ? "Apply by " +
                    getShortApplicationDeadline(time: task.applicationDeadline)
                : 'Open application',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

class BigTaskCard extends StatelessWidget {
  final Task task;
  final bool orangeBackground;
  final String imageURL;
  final Function onTap;
  final bool isDisplayTask;
  final bool hasUnreadMessage;
  final bool newTask;
  final String uni;

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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  const BigTaskCard(
      {Key key,
      @required this.task,
      this.orangeBackground = false,
      @required this.imageURL,
      @required this.onTap,
      this.isDisplayTask = true,
      this.newTask = false,
        @required this.uni,
      this.hasUnreadMessage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.all(0),
      splashColor: Colors.transparent,
      highlightColor: Colors.black12,
      onPressed: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: ListDisplayPicture(
                    imageUrl: imageURL,
                    height: 56,
                  ),
                ),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (newTask)
                          Text(
                            'New',
                            style: TextStyle(
                              color: Color(kGenchiOrange)
                            ),

                          ),
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: hasUnreadMessage
                                  ? FontWeight.w500
                                  : FontWeight.w400),
                        ),
                        Text(
                          task.hasFixedDeadline &&
                                  task.applicationDeadline != null
                              ? "Apply by " +
                                  getShortApplicationDeadline(
                                      time: task.applicationDeadline)
                              : 'Open application',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                //TODO: temporary
                // Text(uni,
                // style: TextStyle(
                //   fontWeight: FontWeight.w400,
                //   color: Color(kGenchiOrange)
                // ),),
              ],
            ),
          ),
          // Wrap(
          //   alignment: WrapAlignment.start,
          //   children: _otherChipBuilder(tags: task.tags),
          // ),
          SizedBox(height: 5),
          Divider(
            height: 0,
            thickness: 1,
          )
        ],
      ),
    );
  }
}
