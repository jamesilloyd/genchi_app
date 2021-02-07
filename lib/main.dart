import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/application_chat_screen.dart';
import 'package:genchi_app/screens/customer_needs_screen.dart';
import 'package:genchi_app/screens/edit_account_settings_screen.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:genchi_app/screens/favourites_screen.dart';
import 'package:genchi_app/screens/forgot_password_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/onboarding_screen.dart';
import 'package:genchi_app/screens/post_reg_details_screen.dart';
import 'package:genchi_app/screens/post_task_and_hirer_screen.dart';
import 'package:genchi_app/screens/splash_screen.dart';
import 'package:genchi_app/screens/task_screen_applicant.dart';
import 'package:genchi_app/screens/task_screen_hirer.dart';
import 'package:genchi_app/screens/test_screen.dart';
import 'package:genchi_app/screens/university_not_listed_screen.dart';
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

class _GenchiState extends State<Genchi> {
  ///Initialise FlutterFire
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  /// This is for better handling of dynamic links


  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {

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



class StartUp extends StatefulWidget{
  @override
  _StartUpState createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  // final DynamicLinkService dynamicLinkService = DynamicLinkService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // dynamicLinkService.initDynamicLinks();
  }



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
              primarySwatch: kMaterialGenchiGreen,
              textSelectionTheme: TextSelectionThemeData(
                selectionHandleColor: Color(kGenchiOrange),
                selectionColor: Color(kGenchiLightOrange),
                cursorColor: Color(kGenchiOrange),
              ),
              scaffoldBackgroundColor: Colors.white,
              primaryColor: Color(kGenchiOrange),
              indicatorColor: Color(kGenchiOrange),
              accentColor: Color(kGenchiOrange),
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
              PostTaskAndHirerScreen.id: (context) => PostTaskAndHirerScreen(),
              CustomerNeedsScreen.id: (context) => CustomerNeedsScreen(),
              UniversityNotListedScreen.id: (context) => UniversityNotListedScreen(),
            },
          );
        }

        /// The async function is still loading
        return SplashScreen();
      },
    );
  }
}
