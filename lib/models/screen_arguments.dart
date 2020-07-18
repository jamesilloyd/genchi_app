import 'package:flutter/material.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';

class SearchProviderScreenArguments {
  //ToDO: change this when using service as a class
  final Map service;

  SearchProviderScreenArguments({@required this.service});
}

class ProviderScreenArguments {

  //ToDo: now using provider package so may not need this
  final ProviderUser provider;

  ProviderScreenArguments({@required this.provider});

}

class HomeScreenArguments {

  final int startingIndex;

  HomeScreenArguments({this.startingIndex = 0});
}

class ChatScreenArguments {

  final Chat chat;
  final bool userIsProvider;
  final User user;
  final ProviderUser provider;
  final bool isFirstInstance;

  ChatScreenArguments({this.chat,this.userIsProvider = false, this.provider, this.user, this.isFirstInstance = false});

}



class ApplicationChatScreenArguments {

  final TaskApplicant taskApplicant;
  final bool userIsProvider;
  final User hirer;
  final ProviderUser provider;

  ApplicationChatScreenArguments({@required this.taskApplicant, @required this.userIsProvider, @required this.hirer, @required this.provider});

}