import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class User extends ChangeNotifier {

  ///For all account types
  String accountType;
  String id;
  String email;
  String name;
  String bio;
  String displayPictureFileName;
  String displayPictureURL;
  Timestamp timeStamp;
  List<dynamic> tasksApplied;
  List<dynamic> chats;
  List<dynamic> favourites;
  List<dynamic> isFavouritedBy;
  List<dynamic> posts;
  List<dynamic> fcmTokens;

  ///For societies, charities and service Provider
  String category;

  ///For service Providers
  String mainAccountId;

  ///For individuals
  List<dynamic> providerProfiles;

  bool admin;

  User({
    this.accountType,
    this.id,
    this.email,
    this.name,
    this.bio,
    this.displayPictureFileName,
    this.displayPictureURL,
    this.timeStamp,
    this.tasksApplied,
    this.chats,
    this.favourites,
    this.isFavouritedBy,
    this.posts,
    this.fcmTokens,
    this.category,
    this.mainAccountId,
    this.providerProfiles,
    this.admin,
  });
  //TODO delete the type redundancy after successfull migration
  User.fromMap(Map snapshot)
      : accountType = snapshot['accountType'] ?? 'Individual',
        id = snapshot['id'] ?? snapshot['pid'],
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        bio = '${snapshot['bio']??''} ${snapshot['experience'] ?? ''}',
        displayPictureFileName = snapshot['displayPictureFileName'],
        displayPictureURL = snapshot['displayPictureURL'],
        timeStamp = snapshot['timeStamp'],
        tasksApplied = snapshot['tasksApplied'] ?? [],
        chats = snapshot['chats'] ?? [],
        favourites = snapshot['favourites'] ?? [],
        isFavouritedBy = snapshot['isFavouritedBy'] ?? [],
        posts = snapshot['posts'] ?? [],
        fcmTokens = snapshot['fcmTokens'] ?? [],
        category = snapshot['category'] ?? snapshot['type'] ?? '',
        mainAccountId = snapshot['mainAccountId'] ?? snapshot['uid'],
        providerProfiles = snapshot['providerProfiles'] ?? [],
        admin = snapshot['admin'] ?? false;

  toJson() {
    return {
      if (accountType != null) "accountType": accountType,
      if (id != null) 'id': id,
      if (email != null) "email": email,
      if (name != null) "name": name,
      if (bio != null) "bio": bio,
      if (displayPictureFileName != null)
        "displayPictureFileName": displayPictureFileName,
      if (displayPictureURL != null) 'displayPictureURL': displayPictureURL,
      if (timeStamp != null) 'timeStamp' : timeStamp,
      if (tasksApplied != null) 'tasksApplied': tasksApplied,
      if (chats != null) 'chats': chats,
      if (favourites != null) 'favourites': favourites,
      if (isFavouritedBy != null) 'isFavouritedBy' : isFavouritedBy,
      if (posts != null) 'posts': posts,
      if (fcmTokens != null) 'fcmTokens': fcmTokens,
      if (category != null) "category": category,
      if (mainAccountId != null) 'mainAccountId' : mainAccountId,
      if (providerProfiles != null) 'providerProfiles': providerProfiles,
      if (admin != null) 'admin': admin,
    };
  }
}

List<String> accountTypeList = ['Individual', 'Society', 'Charity'];
///and 'Service Provider'

List<String> societyCategoryList = ['Sports'];

List<String> charityCategoryList = ['???'];
