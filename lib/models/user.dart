import 'package:flutter/widgets.dart';

class User extends ChangeNotifier {

  String accountType;

  ///For all account types
  String id;
  String email;
  String name;
  String bio;
  String displayPictureFileName;
  String displayPictureURL;
  DateTime timeStamp;
  List<dynamic> tasksApplied;
  List<dynamic> chats;
  List<dynamic> favourites;
  List<dynamic> posts;
  List<dynamic> fcmTokens;

  ///For societies, charities and services
  String category;

  ///For providers
  String mainAccountId;

  ///For individuals
  List<dynamic> providerProfiles;


  bool admin;

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
      this.accountType,
      this.category,
      this.bio,
      this.tasksApplied,
      this.admin,
      this.chats});

  User.fromMap(Map snapshot)
      : email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        accountType = snapshot['accountType'] ?? 'Individual',
        category = snapshot['category'] ?? '',
        bio = snapshot['bio'] ?? '',
        displayPictureFileName = snapshot['displayPictureFileName'],
        displayPictureURL = snapshot['displayPictureURL'],
        id = snapshot['id'] ?? '',
        providerProfiles = snapshot['providerProfiles'] ?? [],
        favourites = snapshot['favourites'] ?? [],
        fcmTokens = snapshot['fcmTokens'] ?? [],
        tasksApplied = snapshot['tasksApplied'] ?? [],
        posts = snapshot['posts'] ?? [],
        admin = snapshot['admin'] ?? false,
        chats = snapshot['chats'] ?? [];

  toJson() {
    return {
      if (email != null) "email": email,
      if (name != null) "name": name,
      if (admin != null) 'admin': admin,
      if (accountType != null) "accountType": accountType,
      if (category != null) "category": category,
      if (bio != null) "bio": bio,
      if (displayPictureFileName != null)
        "displayPictureFileName": displayPictureFileName,
      if (displayPictureURL != null) 'displayPictureURL': displayPictureURL,
      if( tasksApplied != null) 'tasksApplied' : tasksApplied,
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

List<String> accountTypeList = ['Individual', 'Society', 'Charity'];

List<String> societyCategoryList = ['Sports'];

List<String> charityCategoryList = ['???'];
