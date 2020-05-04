import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:genchi_app/constants.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chat_summary_screen.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context)  {
    final authProvider = Provider.of<AuthenticationService>(context);
    print("Home screen ${authProvider.currentUser}");

    //ToDo, Change this to a normal tab contorller or conditional on device. What is the functional difference between the different types
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Color(kGenchiCream),
          activeColor: Color.fromRGBO(241,147, 0, 100),
          items: [
        BottomNavigationBarItem(
          icon: Icon(Platform.isIOS ? CupertinoIcons.search : Icons.search),
          title: Text('Search'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Platform.isIOS ? CupertinoIcons.conversation_bubble : Icons.message),
          title: Text('Messages'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Platform.isIOS ? CupertinoIcons.profile_circled : Icons.account_circle),
          title: Text('Profile'),
        ),
      ]),
      tabBuilder: (context, index) {
        if (index == 0) {
          return SearchScreen();
        } else if (index == 1) {
          return ChatSummaryScreen();
        } else {
          return ProfileScreen();
        }
      },
    );
  }
}