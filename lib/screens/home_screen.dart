import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'chat_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chat_summary_screen.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/CRUDModel.dart';

FirebaseUser loggedInUser;

class HomeScreen extends StatefulWidget {

  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  final _auth = FirebaseAuth.instance;
  //ToDO: need to implment this in main (top of the tree)
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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