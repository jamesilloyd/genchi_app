import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/jobs_screen.dart';
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

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  static List<Widget> screens = [
    JobsScreen(),
    SearchScreen(),
    ChatSummaryScreen(),
    ProfileScreen(),
  ];

  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  DefaultCacheManager cacheManager = DefaultCacheManager();
  StreamSubscription iosSubscription;

  _saveDeviceToken() async {
    /// Get the current user
    GenchiUser currentUser = Provider.of<AuthenticationService>(context, listen: false)
            .currentUser;

    /// Get the token for this device
    String fcmToken = await _fcm.getToken();

    /// Save it to Firestore
    if (fcmToken != null) {
      firestoreAPI.addFCMToken(token: fcmToken, user: currentUser);
    }
  }


  //TODO move fcm token to login/registration
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


    return Scaffold(
      //TODO: look into using a page view instead
      // body: IndexedStack(
      //   index: _page ?? startingIndex,
      //   children: screens,
      // ),
      body: screens.elementAt(_page ?? startingIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 1)]),
        /*TODO: look at wrapping just the following widget in a Provider and
            hopefully it means the whole app won't be rebuilt, just the subsequent widget
         */
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
                icon: Stack(
                  alignment: Alignment.center,
                  children: [Icon(Platform.isIOS
                      ? CupertinoIcons.home
                      : Icons.home_outlined),
                  ]
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon:
                    Icon(Platform.isIOS ? CupertinoIcons.search : Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Platform.isIOS
                    ? CupertinoIcons.conversation_bubble
                    : Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Platform.isIOS
                    ? (authProvider.currentUser.providerProfiles.isEmpty
                        ? CupertinoIcons.profile_circled
                        : CupertinoIcons.group)
                    : (authProvider.currentUser.providerProfiles.isEmpty
                        ? Icons.account_circle
                        : Icons.group)),
                label: authProvider.currentUser.providerProfiles.isEmpty
                    ? 'Profile'
                    : 'Profiles',
              ),
            ]),
      ),
    );
  }
}
