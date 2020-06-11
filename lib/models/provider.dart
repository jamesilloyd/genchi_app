import 'package:flutter/widgets.dart';

class ProviderUser extends ChangeNotifier {
  String uid;
  String pid;
  String name;
  String displayPictureFileName;
  String displayPictureURL;
  DateTime timeStamp;
  String bio;
  String experience;
  String type;
  String pricing;
  bool isDeleted;
  List<dynamic> chats;
  List<dynamic> isFavouritedBy;

  ProviderUser(
      {this.uid,
      this.pid,
      this.name,
      this.displayPictureURL,
      this.displayPictureFileName,
      this.timeStamp,
      this.bio,
      this.type,
      this.chats,
      this.pricing,
      this.isDeleted,
      this.isFavouritedBy,
      this.experience});

  ProviderUser.fromMap(Map snapshot)
      : uid = snapshot['uid'] ?? '',
        pid = snapshot['pid'] ?? '',
        name = snapshot['name'] ?? '',
        pricing = snapshot['pricing'] ?? '',
        displayPictureURL = snapshot['displayPictureURL'],
        displayPictureFileName = snapshot['displayPictureFileName'],
        //ToDo: need to fix mismatch in data types of flutter and firebase timestamps
//        timeStamp = snapshot['timestamp'],
        bio = snapshot['bio'] ?? '',
        chats = snapshot['chats'] ?? [],
        isDeleted = snapshot['isDeleted'] ?? false,
        experience = snapshot['experience'] ?? '',
        isFavouritedBy = snapshot['isFavouritedBy'] ?? [],
        type = snapshot['type'] ?? '';

  toJson() {
    return {
      if (uid != null) 'uid': uid,
      if (pid != null) 'pid': pid,
      if (name != null) "name": name ?? '',
      if (pricing != null) "pricing": pricing ?? '',
      if (displayPictureURL != null) "displayPictureURL": displayPictureURL,
      if (displayPictureFileName != null)
        "displayPictureFileName": displayPictureFileName,
      if (bio != null) "bio": bio,
      if (type != null) 'type': type,
      if (isDeleted != null) 'isDeleted': isDeleted,
      if (timeStamp != null) 'timeStamp': timeStamp,
      if (chats != null) 'chats': chats,
      if (isFavouritedBy != null) 'isFavouritedBy': isFavouritedBy,
      if (experience != null) 'experience': experience,
    };
  }
}
