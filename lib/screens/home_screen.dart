import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
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
import 'package:flutter_app_badger/flutter_app_badger.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page;
  final pageController = PageController();

  List<Widget> _children = [JobsScreen(), ChatSummaryScreen(), ProfileScreen()];

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  final DynamicLinkService dynamicLinkService = DynamicLinkService();
  Future notificationsFuture;

  Future<void> saveTokenToDatabase(String token) async {
    String token = await FirebaseMessaging.instance.getToken();

    print('saving new token: $token');
    // Assume user is logged in for this example
    /// Get the current user
    GenchiUser currentUser =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;

    /// Save it to Firestore
    if (token != null) {
      firestoreAPI.addFCMToken(token: token, user: currentUser);
    }

    print('saved token to firebase');
  }

  void listenForPushNotifications() async {



    ///This listens to messages in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Map<String, String> data = message.data;
      print(message);
      // Owner owner = Owner.fromMap(jsonDecode(data['owner']));
      // User user = User.fromMap(jsonDecode(data['user']));
      // Picture picture = Picture.fromMap(jsonDecode(data['picture']));
      //
      // print('The user ${user.name} liked your picture "${picture.title}"!');
    });

    /// Get any messages which caused the application to open from a terminated state.
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    print(initialMessage);

    ///Example of how to handle the message
    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    // if (initialMessage?.data['type'] == 'chat') {
    //   Navigator.pushNamed(context, '/chat',
    //       arguments: ChatArguments(initialMessage));
    // }

    /// Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(message);
      // if (message.data['type'] == 'chat') {
      //   Navigator.pushNamed(context, '/chat',
      //       arguments: ChatArguments(message));
      // }
    });

    //TODO: move this somewhere better and integrate with firebase
    if(await FlutterAppBadger.isAppBadgeSupported()){

      FlutterAppBadger.removeBadge();

    }
  }

  @override
  void initState() {
    super.initState();
    print('home');
    GenchiUser user =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    notificationsFuture = firestoreAPI.userHasNotification(user: user);

    Provider.of<NotificationService>(context, listen: false)
        .updateJobNotificationsFire(user: user);

    dynamicLinkService.initDynamicLinks(context);

    listenForPushNotifications();

    saveTokenToDatabase('dummy_token');

    /// Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
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
      //TODO: indexedstack vs pageview
        body: IndexedStack(
          index: _page ?? startingIndex,
          children: _children,
        ),
      // PageView(
      //   children: _children,
      //   controller: pageController,
      //   onPageChanged: onPageChanged,
      // ),
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

            //     (int index) {
            //   pageController.jumpToPage(index);
            // },
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
                                color: notificationsProvider.notifications > 0
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
