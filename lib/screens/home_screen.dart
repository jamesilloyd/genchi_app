import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/jobs_screen.dart';
import 'package:genchi_app/services/dynamic_link_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/notification_service.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int _page;
  final pageController = PageController();

  //TODO: may need to put this in init
  // static List<Widget> _children = [JobsScreen(), ChatSummaryScreen(), ProfileScreen()];
  List<Widget> _children;

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  final DynamicLinkService dynamicLinkService = DynamicLinkService();
  DefaultCacheManager cacheManager = DefaultCacheManager();
  StreamSubscription iosSubscription;
  Future notificationsFuture;

  _saveDeviceToken() async {
    /// Get the current user
    GenchiUser currentUser =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;

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
    print('home');
    GenchiUser user =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    // notificationsFuture = firestoreAPI.userHasNotification(user: user);

    Provider.of<NotificationService>(context, listen: false).updateJobNotificationsFire(user: user);
    _children = [JobsScreen(),ChatSummaryScreen(),ProfileScreen()];

    dynamicLinkService.initDynamicLinks(context);

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
    final notificationsProvider = Provider.of<NotificationService>(context);
    print('Home screen: user is ${authProvider.currentUser.id}');

    return Scaffold(
      //TODO: look into using a page view instead
      body: PageView(
        children: _children,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
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
            onTap: (int index) {
              pageController.jumpToPage(index);
            },
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Stack(alignment: Alignment.center, children: [
                  Icon(Platform.isIOS
                      ? CupertinoIcons.home
                      : Icons.home_outlined),
                ]),
                label: 'Home',
              ),
              // BottomNavigationBarItem(
              //   icon:
              //       Icon(Platform.isIOS ? CupertinoIcons.search : Icons.search),
              //   label: 'Search',
              // ),
              BottomNavigationBarItem(
                icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Icon(Platform.isIOS
                              ? CupertinoIcons.conversation_bubble
                              : Icons.message),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 9,
                            width: 9,
                            decoration: BoxDecoration(
                                color: notificationsProvider.notifications  > 0
                                    ? Color(kGenchiOrange)
                                    : Colors.transparent,
                                // color: Color(kGenchiGreen),
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                      )
                    ]),
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
