import 'package:cloud_firestore/cloud_firestore.dart';

class GenchiUser {
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
  List<dynamic> preferences;
  Map draftJob;
  String university;
  String versionNumber;
  int sessionCount;

  //TODO: this is temporary
  bool hasSetPreferences;

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

  List<String> accessibleUniversities = [
    'Cambridge',
    'Harvard',
    'MIT',
  ];


  GenchiUser({
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
    this.draftJob,
    this.category,
    this.subcategory,
    this.mainAccountId,
    this.providerProfiles,
    this.admin,
    this.versionNumber,
    this.preferences,
    this.university,
    this.sessionCount,
    //TODO: this is temporary
    this.hasSetPreferences,
  });

  GenchiUser.fromMap(Map snapshot)
      : accountType = snapshot['accountType'] ?? 'Individual',
        id = snapshot['id'] ?? '',
        email = snapshot['email'] ?? '',
        name = snapshot['name'] ?? '',
        bio = snapshot['bio'] ?? '',
        displayPictureFileName = snapshot['displayPictureFileName'],
        // displayPictureURL = 'https://firebasestorage.googleapis.com/v0/b/genchi-c96c1.appspot.com/o/images%2Fusers%2FuS1se30jxrfLO0uJNB12ns0Hr8r22020-10-21%2016%3A37%3A40.270658.png?alt=media&token=6ee7b906-7e45-44c1-85ff-2811b4989f8f',
        // displayPictureURL = 'https://firebasestorage.googleapis.com/v0/b/genchi-c96c1.appspot.com/o/images%2Fusers%2FuS1se30jxrfLO0uJNB12ns0Hr8r22020-10-21%2016%3A37%3A40.270658_100x100.png?alt=media&token=5236c2c7-6047-49bb-bf26-a8eb21a559e0',
        displayPictureURL = snapshot['displayPictureURL'],
        timeStamp = snapshot['timeStamp'],
        tasksApplied = snapshot['tasksApplied'] ?? [],
        chats = snapshot['chats'] ?? [],
        favourites = snapshot['favourites'] ?? [],
        isFavouritedBy = snapshot['isFavouritedBy'] ?? [],
        posts = snapshot['posts'] ?? [],
        fcmTokens = snapshot['fcmTokens'] ?? [],
        draftJob = snapshot['draftJob'] ?? {},
        category = snapshot['category'] ?? snapshot['type'] ?? '',
        subcategory = snapshot['subcategory'] ?? '',
        mainAccountId = snapshot['mainAccountId'] ?? snapshot['uid'],
        providerProfiles = snapshot['providerProfiles'] ?? [],
        preferences = snapshot['preferences'] ?? [],
        //TODO: this is temporary
        hasSetPreferences = snapshot['hasSetPreferences'] ?? false,
        university = snapshot['university'] ?? 'Cambridge',
        versionNumber = snapshot['versionNumber'] ?? "1.0.0",
        sessionCount = snapshot['sessionCount'] ?? 0,
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
      if (timeStamp != null) 'timeStamp': timeStamp,
      if (tasksApplied != null) 'tasksApplied': tasksApplied,
      if (chats != null) 'chats': chats,
      if (favourites != null) 'favourites': favourites,
      if (isFavouritedBy != null) 'isFavouritedBy': isFavouritedBy,
      if (posts != null) 'posts': posts,
      if (fcmTokens != null) 'fcmTokens': fcmTokens,
      if (draftJob != null) 'draftJob' : draftJob,
      if (category != null) "category": category,
      if (subcategory != null) 'subcategory': subcategory,
      if (mainAccountId != null) 'mainAccountId': mainAccountId,
      if (providerProfiles != null) 'providerProfiles': providerProfiles,
      if (preferences != null) 'preferences' : preferences,
      if (university != null) 'university' : university,
      if (versionNumber != null) 'versionNumber' : versionNumber,
      //TODO: this is temporary
      if (hasSetPreferences != null) 'hasSetPreferences':hasSetPreferences,
      if (sessionCount != null) 'sessionCount':sessionCount,
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

  Service(
      {this.nameSingular,
      this.namePlural,
      this.imageAddress,
      this.databaseValue});
}

List<Service> servicesList = [
  Service(
      nameSingular: 'Designer',
      namePlural: 'Designers',
      imageAddress: 'images/service_icons/designers.png',
      databaseValue: 'Design'),
  Service(
      nameSingular: 'Entertainment',
      namePlural: 'Entertainment',
      imageAddress: 'images/service_icons/entertainment.png',
      databaseValue: 'Entertainment'),
  Service(
      nameSingular: 'Journalist',
      namePlural: 'Journalists',
      imageAddress: 'images/service_icons/tutors.png',
      databaseValue: 'Journalism'),
  Service(
      nameSingular: 'Photographer',
      namePlural: 'Photographers',
      imageAddress: 'images/service_icons/photographers.png',
      databaseValue: 'Photography'),
  Service(
      nameSingular: 'Researcher',
      namePlural: 'Researchers',
      imageAddress: 'images/service_icons/research.png',
      databaseValue: 'Research'),
  Service(
      nameSingular: 'Software',
      namePlural: 'Software',
      imageAddress: 'images/service_icons/software.png',
      databaseValue: 'Software'),
  Service(
      nameSingular: 'Other',
      namePlural: 'Other',
      imageAddress: 'images/service_icons/other.png',
      databaseValue: 'Other'),
];

//TODO: this is a temporary measure CHANGE
List<Service> opportunityTypeList = [
  Service(
      nameSingular: 'Designer',
      namePlural: 'Designers',
      databaseValue: 'Design'),
  Service(
      nameSingular: 'Journalist',
      namePlural: 'Journalists',
      databaseValue: 'Journalism'),
  Service(
      nameSingular: 'Photographer',
      namePlural: 'Photographers',
      databaseValue: 'Photography'),
  Service(
      nameSingular: 'Project',
      namePlural: 'Projects',
      databaseValue: 'Project'),
  Service(
      nameSingular: 'Recruitment',
      namePlural: 'Recruitment',
      databaseValue: 'Recruitment'),
  Service(
      nameSingular: 'Researcher',
      namePlural: 'Researchers',
      databaseValue: 'Research'),
  Service(
      nameSingular: 'Software',
      namePlural: 'Software',
      databaseValue: 'Software'),
  Service(
      nameSingular: 'Training',
      namePlural: 'Training',
      databaseValue: 'Training'),
  Service(
      nameSingular: 'Other',
      namePlural: 'Other',
      databaseValue: 'Other'),
];


class GroupType {
  String nameSingular;
  String namePlural;
  String imageAddress;

  ///Don't change this value
  String databaseValue;

  GroupType(
      {this.nameSingular,
      this.namePlural,
      this.imageAddress,
      this.databaseValue});
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
