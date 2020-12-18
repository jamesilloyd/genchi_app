import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/application_chat_screen.dart';
import 'package:genchi_app/screens/edit_account_settings_screen.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:genchi_app/screens/favourites_screen.dart';
import 'package:genchi_app/screens/forgot_password_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/onboarding_screen.dart';
import 'package:genchi_app/screens/post_reg_details_screen.dart';
import 'package:genchi_app/screens/splash_screen.dart';
import 'package:genchi_app/screens/task_screen_applicant.dart';
import 'package:genchi_app/screens/task_screen_hirer.dart';
import 'package:genchi_app/screens/test_screen.dart';
import 'package:genchi_app/screens/user_screen.dart';
import 'package:genchi_app/screens/welcome_screen.dart';
import 'package:genchi_app/screens/login_screen.dart';
import 'package:genchi_app/screens/registration_screen.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'package:genchi_app/screens/edit_account_screen.dart';
import 'package:genchi_app/screens/edit_provider_account_screen.dart';
import 'package:genchi_app/screens/about_screen.dart';
import 'package:genchi_app/screens/post_task_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/dynamic_link_service.dart';
import 'package:genchi_app/services/task_service.dart';

import 'services/authentication_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';


void main() {
  runApp(Genchi());
}

class Genchi extends StatefulWidget {
  @override
  _GenchiState createState() => _GenchiState();
}

//TODO: need to add code to hand dynamic links
//TODO: not quite ready for this
// class _GenchiState extends State<Genchi> with WidgetsBindingObserver {
class _GenchiState extends State<Genchi> {
  ///Initialise FlutterFire
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  //
  // Timer _timerLink;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  // }
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if(state == AppLifecycleState.resumed){
  //     _timerLink = new Timer(const Duration(milliseconds: 1000), (){
  //       _dynamicLinkService.retrieveDynamicLink(context);
  //     },);
  //   }
  //
  // }
  //
  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   if (_timerLink != null){
  //     _timerLink.cancel();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {

    // return Container(color: Colors.red);
    print('Genchi main activated');

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          //TODO: add an error screen in here
        }

        if (snapshot.connectionState == ConnectionState.done) {
          ///Firebase initialised
          ///Override flutterError for crashlytics collection


          if (kDebugMode) {
            /// Force disable Crashlytics collection while doing every day development.
            /// Temporarily toggle this to true if you want to test crash reporting in your app.
            FirebaseCrashlytics.instance
                .setCrashlyticsCollectionEnabled(false);
          } else {


          }
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;


          return MultiProvider(
            providers: [
              // ChangeNotifierProvider(create: (_) =>),
              ChangeNotifierProvider(create: (_) => AuthenticationService()),
              ChangeNotifierProvider(create: (_) => AccountService()),
              //TODO: implement this
              // ChangeNotifierProvider(create: (_) => NotificationService()),
              ChangeNotifierProvider(create: (_) => TaskService()),
            ],
            child: StartUp(),
          );
        }
        return SplashScreen();
      },
    );
  }
}



class StartUp extends StatelessWidget{
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {

    print('StartUp screen activated');
    return FutureBuilder(
      future: Provider.of<AuthenticationService>(context, listen: false)
          .isUserLoggedIn(),
      builder: (context, snapshot) {

        if (snapshot.hasData) {
          bool loggedIn = snapshot.data;
          return MaterialApp(
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            theme: ThemeData(
              fontFamily: 'FuturaPT',
              canvasColor: Colors.white,
              cursorColor: Color(kGenchiOrange),
              scaffoldBackgroundColor: Colors.white,
              primaryColor: Color(kGenchiOrange),
              indicatorColor: Color(kGenchiOrange),
              textSelectionHandleColor: Color(kGenchiOrange),
              accentColor: Color(kGenchiOrange),
              textSelectionColor: Color(kGenchiLightOrange),
              hintColor: Colors.black45,
            ),
            initialRoute: loggedIn ? HomeScreen.id : WelcomeScreen.id,
            routes: {
              WelcomeScreen.id: (context) => WelcomeScreen(),
              LoginScreen.id: (context) => LoginScreen(),
              RegistrationScreen.id: (context) => RegistrationScreen(),
              ChatScreen.id: (context) => ChatScreen(),
              HomeScreen.id: (context) => HomeScreen(),
              EditAccountScreen.id: (context) => EditAccountScreen(),
              ForgotPasswordScreen.id: (context) => ForgotPasswordScreen(),
              EditProviderAccountScreen.id: (context) =>
                  EditProviderAccountScreen(),
              FavouritesScreen.id: (context) => FavouritesScreen(),
              AboutScreen.id: (context) => AboutScreen(),
              PostTaskScreen.id: (context) => PostTaskScreen(),
              TaskScreenHirer.id: (context) => TaskScreenHirer(),
              TaskScreenApplicant.id: (context) => TaskScreenApplicant(),
              EditTaskScreen.id: (context) => EditTaskScreen(),
              TestScreen.id: (context) => TestScreen(),
              ApplicationChatScreen.id: (context) => ApplicationChatScreen(),
              OnboardingScreen.id: (context) => OnboardingScreen(),
              EditAccountSettingsScreen.id: (context) =>
                  EditAccountSettingsScreen(),
              UserScreen.id: (context) => UserScreen(),
              PostRegDetailsScreen.id: (context) => PostRegDetailsScreen(),
            },
          );
        }

        /// The async function is still loading
        return SplashScreen();
      },
    );
  }
}
