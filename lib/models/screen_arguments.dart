import 'package:flutter/material.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';

class HomeScreenArguments {

  final int startingIndex;

  HomeScreenArguments({this.startingIndex = 0});
}

class ChatScreenArguments {

  final Chat chat;
  final bool userIsUser1;
  final GenchiUser user1;
  final GenchiUser user2;
  final bool isFirstInstance;

  ChatScreenArguments({@required this.chat,@required this.userIsUser1, @required this.user1, @required this.user2, this.isFirstInstance = false});

}

class ApplicationChatScreenArguments {

  final TaskApplication taskApplication;
  final bool userIsApplicant;
  final GenchiUser hirer;
  final GenchiUser applicant;

  ApplicationChatScreenArguments({@required this.taskApplication, @required this.userIsApplicant, @required this.hirer, @required this.applicant});

}