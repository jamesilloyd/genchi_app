import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_summary_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chat_summary_screen.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/models/screen_arguments.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

PageController pageController;

class _HomeScreenState extends State<HomeScreen> {

  int _page;

  //TODO: look into why the screens are being called (leading to extra firestore reads)

  void onPageChanged(int page) {

    setState(() {
      this._page = page;
    });
  }

  static List<Widget> screens = [
    SearchScreen(),
    TaskSummaryScreen(),
    ChatSummaryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    print('home screen activated');

    final HomeScreenArguments args =
        ModalRoute.of(context).settings.arguments ?? HomeScreenArguments();
    int startingIndex = args.startingIndex;
    final authProvider = Provider.of<AuthenticationService>(context);
    print('Home screen: user is ${authProvider.currentUser.id}');

    return Scaffold(
      body: screens.elementAt(_page ?? startingIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1)]),
        child: BottomNavigationBar(
          elevation:4,
            currentIndex: _page ?? startingIndex,
            showUnselectedLabels: true,
            selectedItemColor: Color(kGenchiCream),
            unselectedItemColor: Colors.black,
            onTap: onPageChanged,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Platform.isIOS ? CupertinoIcons.search : Icons.search),
                title: Text(
                  'Search',
                  style: TextStyle(fontFamily: 'FuturaPT'),
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                    Platform.isIOS ? CupertinoIcons.folder : Icons.folder_open),
                title: Text('Tasks'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Platform.isIOS
                    ? CupertinoIcons.conversation_bubble
                    : Icons.message),
                title: Text('Messages'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Platform.isIOS
                    ? (authProvider.currentUser.providerProfiles.isEmpty
                        ? CupertinoIcons.profile_circled
                        : CupertinoIcons.group)
                    : (authProvider.currentUser.providerProfiles.isEmpty
                        ? Icons.account_circle
                        : Icons.group)),
                title: Text(authProvider.currentUser.providerProfiles.isEmpty
                    ? 'Profile'
                    : 'Profiles'),
              ),
            ]),
      ),
    );
  }
}
