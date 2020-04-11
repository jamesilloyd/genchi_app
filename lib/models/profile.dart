import 'package:flutter/widgets.dart';
import 'dart:collection';
import 'package:provider/provider.dart';


class Profile extends ChangeNotifier {

  String id;
  String email;
  String name;
  String profilePicture;
  DateTime timeStamp;
  String bio;


  Profile({this.id, this.bio, this.email, this.name, this.profilePicture, this.timeStamp});


  Profile.fromMap(Map snapshot,String id) :
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        profilePicture = snapshot['profilePicture'] ?? '',
        id = snapshot['id'],
        timeStamp = snapshot['timestamp'],
        bio = snapshot['bio'];

  toJson() {
    return {
      "email": email,
      "name": name,
      "profilePicture": profilePicture,
      "bio": bio,
      'id' : id,
      'timeStamp' : timeStamp
    };
  }
}


//class Profile extends ChangeNotifier {
//
//  String _name = "James Lloyd";
//
//  String get name {
//    return _name;
//  }
//
//  void changeName(String newName){
//    _name = newName;
//    notifyListeners();
//  }
//
//}