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
  List<dynamic> chats;
  List<dynamic> isFavouritedBy;
  List<dynamic> tasksApplied;


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
      this.isFavouritedBy,
      this.tasksApplied,
      this.experience});

  ProviderUser.fromMap(Map snapshot)
      : uid = snapshot['uid'] ?? '',
        pid = snapshot['pid'] ?? '',
        name = snapshot['name'] ?? '',
        pricing = snapshot['pricing'] ?? '',
        displayPictureURL = snapshot['displayPictureURL'],
        displayPictureFileName = snapshot['displayPictureFileName'],
        bio = snapshot['bio'] ?? '',
        chats = snapshot['chats'] ?? [],
        experience = snapshot['experience'] ?? '',
        isFavouritedBy = snapshot['isFavouritedBy'] ?? [],
        tasksApplied = snapshot['tasksApplied'] ?? [],
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
      if (timeStamp != null) 'timeStamp': timeStamp,
      if (chats != null) 'chats': chats,
      if (isFavouritedBy != null) 'isFavouritedBy': isFavouritedBy,
      if (experience != null) 'experience': experience,
      if (tasksApplied != null) 'tasksApplied': tasksApplied,
    };
  }
}
