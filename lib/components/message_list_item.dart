import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/time_formatting.dart';

class MessageListItem extends StatelessWidget {
  final String imageURL;
  final String name;
  final String lastMessage;
  final Timestamp time;
  final bool hasUnreadMessage;
  final Function onTap;
  final Function hideChat;
  final String deleteMessage;

  const MessageListItem(
      {Key key,
      @required this.imageURL,
      @required this.hideChat,
      @required this.name,
      @required this.lastMessage,
      @required this.time,
      @required this.hasUnreadMessage,
      @required this.onTap,
      this.deleteMessage = 'Archive'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 5),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 30,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'FuturaPT',
                    fontWeight:
                        hasUnreadMessage ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
            subtitle: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14),
            ),
            leading: ListDisplayPicture(
              imageUrl: imageURL,
              height: 56,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  getSummaryTime(time: time),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'FuturaPT',
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),
          Divider(
            height: 0,
            thickness: 1,
          ),
        ],
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: deleteMessage,
          color: Colors.red[900],
          icon: Icons.delete,
          onTap: hideChat,
        ),
      ],
    );
  }
}

class ApplicantListItem extends StatelessWidget {
  final String imageURL;
  final String name;
  final String lastMessage;
  final Timestamp time;
  final bool hasUnreadMessage;
  final Function onTap;

  const ApplicantListItem({
    Key key,
    @required this.imageURL,
    @required this.name,
    @required this.lastMessage,
    @required this.time,
    @required this.hasUnreadMessage,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 30,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontFamily: 'FuturaPT',
                  fontWeight:
                      hasUnreadMessage ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),
          ),
          leading: ListDisplayPicture(
            imageUrl: imageURL,
            height: 56,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                getSummaryTime(time: time),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'FuturaPT',
                ),
              ),
            ],
          ),
          onTap: onTap,
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
      ],
    );
  }
}

class AppliedTaskChat extends StatelessWidget {
  final String imageURL;
  final String title;
  final String lastMessage;
  final Timestamp time;
  final bool hasUnreadMessage;
  final Function onTap;
  final Function hideChat;
  final String deleteMessage;

  const AppliedTaskChat(
      {Key key,
      @required this.imageURL,
      @required this.hideChat,
      @required this.title,
      @required this.lastMessage,
      @required this.time,
      @required this.hasUnreadMessage,
      @required this.onTap,
      this.deleteMessage = 'Withdraw'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 5),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 30,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'FuturaPT',
                    fontWeight:
                        hasUnreadMessage ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
            subtitle: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14),
            ),
            leading: ListDisplayPicture(
              imageUrl: imageURL,
              height: 56,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  'Your Application',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(kGenchiOrange),
                    fontFamily: 'FuturaPT',
                  ),
                ),
                Text(
                  getSummaryTime(time: time),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'FuturaPT',
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),
          Divider(
            height: 0,
            thickness: 1,
          ),
        ],
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: deleteMessage,
          color: Colors.red[900],
          icon: Icons.delete,
          onTap: hideChat,
        ),
      ],
    );
  }
}

class PostedTaskChats extends StatefulWidget {
  final String title;
  final GenchiUser hirer;
  final Timestamp time;

  final String deleteMessage;
  final List<Widget> messages;
  final bool hasUnreadMessage;

  const PostedTaskChats(
      {Key key,
      @required this.title,
      @required this.hirer,
      this.time,
      @required this.messages,
      @required this.hasUnreadMessage,
      this.deleteMessage = 'Remove'})
      : super(key: key);

  @override
  _PostedTaskChats createState() => _PostedTaskChats();
}

class _PostedTaskChats extends State<PostedTaskChats>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Theme(
      data: theme,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Container(
              color: Color(kGenchiCream),
              child: ExpansionTile(
                onExpansionChanged: (bool changed) {
                  changed
                      ? _animationController.forward()
                      : _animationController.reverse();
                },
                backgroundColor: Color(kGenchiCream),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
                tilePadding: const EdgeInsets.symmetric(horizontal: 5),
                leading: ListDisplayPicture(
                  imageUrl: widget.hirer.displayPictureURL,
                  height: 56,
                ),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 30,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: 'FuturaPT',
                        fontWeight: widget.hasUnreadMessage
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                subtitle: Text(
                  '${widget.messages.length} applicant${widget.messages.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Color(kGenchiOrange),
                    fontSize: 16,
                    fontWeight: widget.hasUnreadMessage
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      widget.hasUnreadMessage
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
                      AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: _animationController,
                        size: 20,
                      ),
                      Text(
                        getSummaryTime(time: widget.time),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'FuturaPT',
                        ),
                      ),
                    ],
                  ),
                ),
                children: widget.messages,
              ),
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}

class HirerTaskApplicants extends StatefulWidget {
  final GenchiUser hirer;
  final Task task;

  final String deleteMessage;
  final List<Widget> successfulMessages;
  final List<Widget> unSuccessfulMessages;
  final bool hasUnreadMessage;
  final String subtitleText;

  const HirerTaskApplicants(
      {Key key,
      @required this.hirer,
      @required this.task,
      @required this.successfulMessages,
      @required this.unSuccessfulMessages,
      @required this.hasUnreadMessage,
      @required this.subtitleText,
      this.deleteMessage = 'Remove'})
      : super(key: key);

  @override
  _HirerTaskApplicants createState() => _HirerTaskApplicants();
}

class _HirerTaskApplicants extends State<HirerTaskApplicants>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Theme(
      data: theme,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Container(
          color: Color(kGenchiCream),
          child: ExpansionTile(
            onExpansionChanged: (bool changed) {
              changed
                  ? _animationController.forward()
                  : _animationController.reverse();
            },
            backgroundColor: Color(kGenchiCream),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
            tilePadding: const EdgeInsets.symmetric(horizontal: 5),
            leading: ListDisplayPicture(
              imageUrl: widget.hirer.displayPictureURL,
              height: 56,
            ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 30,
                child: Text(
                  widget.subtitleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: 'FuturaPT',
                    fontWeight: widget.hasUnreadMessage
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
            subtitle: Text(
              "Posted ${getTaskPostedTime(time: widget.task.time)}",
              style: TextStyle(
                color: Color(kGenchiOrange),
                fontSize: 16,
                fontWeight:
                    widget.hasUnreadMessage ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  widget.hasUnreadMessage
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
                  AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animationController,
                    size: 20,
                  ),
                ],
              ),
            ),
            children: [
              if(widget.task.status != 'Vacant') Text(
                'Successful Applicants',
                style: TextStyle(fontSize: 20),
              ),
              if(widget.task.status != 'Vacant') Divider(thickness: 1,height: 1,color: Colors.black12,),
              Column(
                children: widget.successfulMessages,
              ),
              if(widget.task.status != 'Vacant' && widget.unSuccessfulMessages.isNotEmpty) Text(
                'Unsuccessful Applicants',
                style: TextStyle(fontSize: 20),
              ),
              if(widget.task.status != 'Vacant' && widget.unSuccessfulMessages.isNotEmpty) Divider(thickness: 1,height: 1,color: Colors.black12),
              if(widget.task.status != 'Vacant' && widget.unSuccessfulMessages.isNotEmpty) Column(
                children: widget.unSuccessfulMessages,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
