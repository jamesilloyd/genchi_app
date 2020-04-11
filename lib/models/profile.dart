import 'package:flutter/widgets.dart';
import 'dart:collection';

class Profile extends ChangeNotifier {

  String _name = "James Lloyd";

  //ToDo: implement unmodifiablelistview to make the profile data private

  String get name {
    return _name;
  }

  void changeName(String newName){
    _name = newName;
    notifyListeners();
  }

}