import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_summary_screen.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'chat_summary_screen.dart';
import 'dart:io' show Platform;
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
  //TODO: MUST DO THIS look into why the screens are being called (leading to extra firestore reads)

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

  final FirebaseMessaging _fcm = FirebaseMessaging();
  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  StreamSubscription iosSubscription;

  _saveDeviceToken() async {
    /// Get the current user
    User currentUser = Provider.of<AuthenticationService>(context, listen: false)
            .currentUser;

    /// Get the token for this device
    String fcmToken = await _fcm.getToken();

    /// Save it to Firestore
    if (fcmToken != null) {
      firestoreAPI.addFCMToken(token: fcmToken, user: currentUser);

    }
  }

  @override
  void initState() {
    super.initState();


    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('home screen activated');

    final HomeScreenArguments args =
        ModalRoute.of(context).settings.arguments ?? HomeScreenArguments();
    int startingIndex = args.startingIndex;
    final authProvider = Provider.of<AuthenticationService>(context);
    print('Home screen: user is ${authProvider.currentUser.id}');
    if(devMode) {
      print('IN DEVELOP MODE');
    } else {
      print('IN PRODUCTION MODE');
    }

    return Scaffold(
      body: screens.elementAt(_page ?? startingIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1)]),
        child: BottomNavigationBar(
            elevation: 4,
            type: BottomNavigationBarType.fixed,
            currentIndex: _page ?? startingIndex,
            showUnselectedLabels: true,
            selectedFontSize: 14,
            unselectedFontSize: 14,
            selectedItemColor: Color(kGenchiOrange),
            unselectedItemColor: Colors.black,
            onTap: onPageChanged,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon:
                    Icon(Platform.isIOS ? CupertinoIcons.search : Icons.search),
                title: Text('Search'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Platform.isIOS
                    ? CupertinoIcons.folder
                    : Icons.folder_open),

                //TODO WORK OUT HOW TO DO NOTIFICATIONS - problem is in how to get the numbers - would have to stream the user
//                Stack(
//                  children: <Widget>[
//                    Icon(Platform.isIOS
//                        ? CupertinoIcons.folder
//                        : Icons.folder_open),
//                    Positioned(
//                      right: -5,
////                      top: -3,
//                      child: new Container(
//                        padding: EdgeInsets.all(1),
//                        decoration: new BoxDecoration(
//                          color: Colors.red,
//                          borderRadius: BorderRadius.circular(10),
//                        ),
//                        constraints: BoxConstraints(
//                          minWidth: 20,
//                          minHeight: 20,
//                        ),
//                        child: Center(
//                          child: new Text(
//                            '10',
//                            style: new TextStyle(
//                              color: Colors.white,
//                              fontSize: 8,
//                            ),
//                            textAlign: TextAlign.center,
//                          ),
//                        ),
//                      ),
//                    )
//                  ],
//                ),
                title: Text('My Jobs'),
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
