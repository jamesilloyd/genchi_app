import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chat_summary_screen.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/CRUDModel.dart';

FirebaseUser loggedInUser;

class HomeScreen extends StatefulWidget {

  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.search),
          title: Text('Search'),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.conversation_bubble),
          title: Text('Messages'),
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.profile_circled),
          title: Text('Profile'),
        ),
      ]),
      tabBuilder: (context, index) {
        if (index == 0) {
          return SearchScreen();
        } else if (index == 1) {
          return ChatSummaryScreen();
        } else {
          return ProfileScreen(profileId: loggedInUser.uid);
        }
      },
    );
  }
}