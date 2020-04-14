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


  User.fromMap(Map snapshot) :
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        profilePicture = snapshot['profilePicture'] ?? '',
        id = snapshot['id'] ?? '',
        //ToDo: need to fix mismatch in data types of flutter and firebase timestamps
//        timeStamp = snapshot['timestamp'],
        bio = snapshot['bio'] ?? '';

  toJson() {
    return {
      if(email != null) "email" : email,
      if(name != null) "name": name ?? '',
      if(profilePicture != null) "profilePicture": profilePicture,
      if(bio != null) "bio": bio,
      if(id != null) 'id' : id,
      if(timeStamp != null) 'timeStamp' : timeStamp
    };
  }

}
