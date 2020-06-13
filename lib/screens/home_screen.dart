import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:genchi_app/constants.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chat_summary_screen.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/models/screen_arguments.dart';


FirebaseUser loggedInUser;

class HomeScreen extends StatefulWidget {

  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //ToDo: look into why the screens are being called (leading to extra firestore reads)
  @override
  Widget build(BuildContext context) {

    print('home screen activated');

    final HomeScreenArguments args = ModalRoute.of(context).settings.arguments ?? HomeScreenArguments();
    int startingIndex = args.startingIndex;
    final authProvider = Provider.of<AuthenticationService>(context);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: startingIndex,
          backgroundColor: Color(kGenchiCream),
          activeColor: Color(kGenchiOrange),
          inactiveColor: Color(kGenchiBlue),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Platform.isIOS ? CupertinoIcons.search : Icons.search),
              title: Text('Search',style: TextStyle(fontFamily: 'FuturaPT'),),
            ),
            BottomNavigationBarItem(
              icon: Icon(Platform.isIOS
                  ? CupertinoIcons.conversation_bubble
                  : Icons.message),
              title: Text('Messages'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Platform.isIOS
                  ? (authProvider.currentUser.providerProfiles.isEmpty ? CupertinoIcons.profile_circled : CupertinoIcons.group )
                  : (authProvider.currentUser.providerProfiles.isEmpty ? Icons.account_circle : Icons.group)),
              title: Text(authProvider.currentUser.providerProfiles.isEmpty ? 'Profile' : 'Profiles'),
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
