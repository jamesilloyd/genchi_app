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

  //TODO THIS IS TEMPORARY
  Map<String, dynamic> url1;
  Map<String, dynamic> url2;

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
      this.url1,
      this.url2,
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
        experience = snapshot['experience'] ?? '',
        isFavouritedBy = snapshot['isFavouritedBy'] ?? [],
        tasksApplied = snapshot['tasksApplied'] ?? [],
        url1 = snapshot['url1'] ?? {'link':null,'desc':null,},
        url2 = snapshot['url2'] ?? {'link':null,'desc':null,},
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
      if (url1 != null) 'url1': url1,
      if (url2 != null) 'url2': url2,
      if (isFavouritedBy != null) 'isFavouritedBy': isFavouritedBy,
      if (experience != null) 'experience': experience,
      if (tasksApplied != null) 'tasksApplied': tasksApplied,
    };
  }
}
