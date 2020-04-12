import 'package:flutter/widgets.dart';
import 'dart:collection';
import 'package:provider/provider.dart';


class User extends ChangeNotifier {

  String id;
  String email;
  String name;
  String profilePicture;
  DateTime timeStamp;
  String bio;


  User({this.id, this.bio, this.email, this.name, this.profilePicture, this.timeStamp});


  User.fromMap(Map snapshot, String id) :
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        profilePicture = snapshot['profilePicture'] ?? '',
        id = snapshot['id'],
        //ToDo: need to fix mismatch in data types of flutter and firebase timestamps
//        timeStamp = snapshot['timestamp'],
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