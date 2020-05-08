//ToDo: I don't like this method
import 'package:flutter/material.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';

class SearchProviderScreenArguments {
  final String service;

  SearchProviderScreenArguments(this.service);
}


class EditProviderAccountScreenArguments {
  final bool fromRegistration;

  //ToDo: now using provider package so may not need this
  final ProviderUser provider;

  //ToDo: make this so that provider is required
  EditProviderAccountScreenArguments({this.fromRegistration = false, this.provider});
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

  ChatScreenArguments({this.chat,this.userIsProvider = false, this.provider, this.user});

}