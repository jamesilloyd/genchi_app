import 'package:flutter/widgets.dart';

class User extends ChangeNotifier {
  String id;
  String email;
  String name;
  String displayPictureFileName;
  String displayPictureURL;
  DateTime timeStamp;
  List<dynamic> providerProfiles;
  List<dynamic> chats;

  User(
      {this.id,
      this.email,
      this.name,
      this.displayPictureFileName,
      this.displayPictureURL,
      this.timeStamp,
      this.providerProfiles,
      this.chats});

  User.fromMap(Map snapshot)
      : email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        displayPictureFileName = snapshot['displayPictureFileName'],
        displayPictureURL = snapshot['displayPictureURL'],
        id = snapshot['id'] ?? '',
        providerProfiles = snapshot['providerProfiles'] ?? [],
        chats = snapshot['chats'] ?? [];

  toJson() {
    return {
      if (email != null) "email": email,
      if (name != null) "name": name ?? '',
      if (displayPictureFileName != null) "displayPictureFileName": displayPictureFileName,
      if (displayPictureURL != null) 'displayPictureURL' : displayPictureURL,
      if (id != null) 'id': id,
      if (timeStamp != null) 'timeStamp': timeStamp,
      if (providerProfiles != null) 'providerProfiles': providerProfiles,
      if (chats != null) 'chats' : chats,
    };
  }
}
