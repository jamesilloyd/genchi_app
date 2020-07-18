import 'package:flutter/widgets.dart';

class User extends ChangeNotifier {
  String id;
  String email;
  String name;
  String college;
  String subject;
  String bio;
  String displayPictureFileName;
  String displayPictureURL;
  DateTime timeStamp;
  List<dynamic> providerProfiles;
  List<dynamic> chats;
  List<dynamic> favourites;
  List<dynamic> posts;
  List<dynamic> fcmTokens;

  User(
      {this.id,
      this.email,
      this.name,
      this.displayPictureFileName,
      this.displayPictureURL,
      this.timeStamp,
      this.providerProfiles,
      this.favourites,
      this.posts,
      this.fcmTokens,
      this.college,
      this.subject,
      this.bio,
      this.chats});

  User.fromMap(Map snapshot)
      : email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        college = snapshot['college'] ?? '',
        subject = snapshot['subject'] ?? '',
        bio = snapshot['bio'] ?? '',
        displayPictureFileName = snapshot['displayPictureFileName'],
        displayPictureURL = snapshot['displayPictureURL'],
        id = snapshot['id'] ?? '',
        providerProfiles = snapshot['providerProfiles'] ?? [],
        favourites = snapshot['favourites'] ?? [],
        fcmTokens = snapshot['fcmTokens'] ?? [],
        posts = snapshot['posts'] ?? [],
        chats = snapshot['chats'] ?? [];

  toJson() {
    return {
      if (email != null) "email": email,
      if (name != null) "name" : name,
      if (college != null) "college" : college,
      if (subject != null) "subject" : subject,
      if (bio != null) "bio" : bio,
      if (displayPictureFileName != null)
        "displayPictureFileName": displayPictureFileName,
      if (displayPictureURL != null) 'displayPictureURL': displayPictureURL,
      if (id != null) 'id': id,
      if (timeStamp != null) 'timeStamp': timeStamp,
      if (providerProfiles != null) 'providerProfiles': providerProfiles,
      if (chats != null) 'chats': chats,
      if (favourites != null) 'favourites': favourites,
      if (posts != null) 'posts': posts,
      if (fcmTokens != null) 'fcmTokens': fcmTokens,
    };
  }
}
