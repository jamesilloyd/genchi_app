//ToDo: I don't like this method
import 'package:flutter/material.dart';
import 'package:genchi_app/models/provider.dart';

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

//TODO: must find a better way to do this
//TODO: or find a way to only pass argument if you need to change a value (preinitialise)
class HomeScreenArguments {

  final int startingIndex;

  HomeScreenArguments({this.startingIndex = 0});
}