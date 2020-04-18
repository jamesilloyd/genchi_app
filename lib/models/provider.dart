import 'package:flutter/widgets.dart';

class ProviderUser extends ChangeNotifier {

  String uid;
  String pid;
  String name;
  String profilePicture;
  DateTime timeStamp;
  String bio;
  String type;


  ProviderUser({this.uid, this.pid, this.name, this.profilePicture, this.timeStamp, this.bio, this.type});


  ProviderUser.fromMap(Map snapshot) :
        uid = snapshot['email'] ?? '',
        pid = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        profilePicture = snapshot['profilePicture'] ?? '',
  //ToDo: need to fix mismatch in data types of flutter and firebase timestamps
//        timeStamp = snapshot['timestamp'],
        bio = snapshot['bio'] ?? '',
        type = snapshot['email'] ?? '';

  toJson() {
    return {
      if(uid != null) 'uid' : uid,
      if(pid != null) 'pid' : pid,
      if(name != null) "name": name ?? '',
      if(profilePicture != null) "profilePicture": profilePicture,
      if(bio != null) "bio": bio,
      if(type != null) 'type' : type,
      if(timeStamp != null) 'timeStamp' : timeStamp
    };
  }

}
