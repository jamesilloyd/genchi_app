import 'package:flutter/widgets.dart';

class User extends ChangeNotifier {

  String id;
  String email;
  String name;
  String profilePicture;
  DateTime timeStamp;
  String bio;
  List<dynamic> providerProfiles;


  User({this.id, this.bio, this.email, this.name, this.profilePicture, this.timeStamp, this.providerProfiles});


  User.fromMap(Map snapshot) :
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        profilePicture = snapshot['profilePicture'] ?? '',
        id = snapshot['id'] ?? '',
        //ToDo: need to fix mismatch in data types of flutter and firebase timestamps null value needs to return a timestamp type
//        timeStamp = snapshot['timestamp'],
        bio = snapshot['bio'] ?? '',
        providerProfiles = snapshot['providerProfiles'] ?? [''];


  toJson() {
    return {
      if(email != null) "email" : email,
      if(name != null) "name": name ?? '',
      if(profilePicture != null) "profilePicture": profilePicture,
      if(bio != null) "bio": bio,
      if(id != null) 'id' : id,
      if(timeStamp != null) 'timeStamp' : timeStamp,

      if(providerProfiles !=null) 'providerProfiles' : providerProfiles
    };
  }

}
