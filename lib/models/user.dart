import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class User {

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

  ///For groups and service providers
  String category;

  ///For groups
  String subcategory;

  ///For service Providers
  String mainAccountId;

  ///For individuals
  List<dynamic> providerProfiles;

  bool admin;

  static String groupAccount = 'Group';
  static String individualAccount = 'Individual';
  String serviceProviderAccount = 'Service Provider';

  List<String> accessibleAccountTypes = [
    groupAccount,
    individualAccount,
  ];


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
    this.subcategory,
    this.mainAccountId,
    this.providerProfiles,
    this.admin,
  });
  //TODO delete the type redundancy after successfull migration
  User.fromMap(Map snapshot)
      : accountType =  snapshot['accountType'] ?? 'Individual',
        id = snapshot['id'] ?? snapshot['pid'],
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        bio = snapshot['bio'] ?? '',
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
        subcategory = snapshot['subcategory'] ?? snapshot['category'] ?? '',
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
      if (subcategory != null) 'subcategory' : subcategory,
      if (mainAccountId != null) 'mainAccountId' : mainAccountId,
      if (providerProfiles != null) 'providerProfiles': providerProfiles,
      if (admin != null) 'admin': admin,
    };
  }
}


///FOR Service Provider Accounts (Individual on the app)
class Service {

  String nameSingular;
  String namePlural;
  String imageAddress;
  ///Don't change this value
  String databaseValue;

  Service({this.nameSingular, this.namePlural, this.imageAddress, this.databaseValue});
}


List<Service> servicesList = [
  Service(nameSingular: 'Designer',
      namePlural: 'Designers',
      imageAddress: 'images/service_icons/designers.png',
      databaseValue: 'Design'
  ),
  Service(nameSingular: 'Entertainment',
      namePlural: 'Entertainment',
      imageAddress: 'images/service_icons/entertainment.png',
      databaseValue: 'Entertainment'
  ),
  Service(
      nameSingular: 'Journalist',
      namePlural: 'Journalists',
      imageAddress: 'images/service_icons/tutors.png',
      databaseValue: 'Journalism'
  ),
  Service(
      nameSingular: 'Photographer',
      namePlural: 'Photographers',
      imageAddress: 'images/service_icons/photographers.png',
      databaseValue: 'Photography'
  ),
  Service(
      nameSingular: 'Researcher',
      namePlural: 'Researchers',
      imageAddress: 'images/service_icons/research.png',
      databaseValue: 'Research'
  ),
  Service(
      nameSingular: 'Software',
      namePlural: 'Software',
      imageAddress: 'images/service_icons/software.png',
      databaseValue: 'Software'
  ),
  Service(
      nameSingular: 'Other',
      namePlural: 'Other',
      imageAddress: 'images/service_icons/other.png',
      databaseValue: 'Other'
  ),
];


class GroupType {

  String nameSingular;
  String namePlural;
  String imageAddress;
  ///Don't change this value
  String databaseValue;

  GroupType({this.nameSingular, this.namePlural, this.imageAddress, this.databaseValue});
}


List<GroupType> groupsList = [
  GroupType(
    nameSingular: 'Charity',
    namePlural: 'Charities',
    imageAddress: 'images/group_icons/charity.png',
    databaseValue: 'Charity',
  ),
  GroupType(
    nameSingular: 'Entertainment',
    namePlural: 'Entertainment',
    imageAddress: 'images/group_icons/entertainment.png',
    databaseValue: 'Entertainment',
  ),
  GroupType(
    nameSingular: 'Project Group',
    namePlural: 'Project Groups',
    imageAddress: 'images/group_icons/project.png',
    databaseValue: 'Project Group',
  ),
  GroupType(
    nameSingular: 'Society',
    namePlural: 'Societies',
    imageAddress: 'images/group_icons/society.png',
    databaseValue: 'Society',
  ),
  GroupType(
    nameSingular: 'Other',
    namePlural: 'Others',
    imageAddress: 'images/group_icons/other.png',
    databaseValue: 'Other',
  ),
];