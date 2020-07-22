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
            : CircleAvatar(
                backgroundImage: image,
                radius: 30,
                backgroundColor: Color(kGenchiCream),
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
          task.details,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (!isDisplayTask)
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
              task.service,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16,color: Color(kGenchiOrange)),
            ),
            Text(
//              task.date,
              'Posted ${getSummaryTime(time: task.time)}',
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 14),
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

Widget TaskTile(
    {@required Task task,
    @required ImageProvider image,
    @required Function onTap,
    double width = 100,
    @required String name,
    bool isDisplayTask = true,
    bool hasUnreadMessage = false}) {
  return Center(
    child: Container(
      height: width * 1.3,
      width: width,
      decoration: BoxDecoration(
        color: Color(kGenchiBrown),
        border: Border.all(color: Color(0xffc4c4c4), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300],
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 9,
            child: FlatButton(
              onPressed: onTap,
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 1),
              color: Color(kGenchiCream),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    height: 2,
                  ),
                  image == null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xffC4C4C4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              Icons.person,
                              color: Color(0xff585858),
                              size: 30,
                            ),
                          ),
                        )
                      : Center(
                          child: CircleAvatar(
                            backgroundImage: image,
                            radius: 25,
                            backgroundColor: Color(kGenchiCream),
                          ),
                        ),
                  Center(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 1)
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1, -1),
                  end: Alignment(-1, -0.8),
                  colors: [Colors.grey[100], Colors.transparent],
                ),
              ),
              //TODO: need to change this to "time to do task", rather than "time posted"
              child: Center(
                child: Text(
//                  task.date,
                  getSummaryTime(time: task.time),
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
