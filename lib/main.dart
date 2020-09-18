import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/application_chat_screen.dart';
import 'package:genchi_app/screens/edit_account_settings_screen.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';

import 'package:genchi_app/screens/favourites_screen.dart';
import 'package:genchi_app/screens/forgot_password_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/onboarding_screen.dart';
import 'package:genchi_app/screens/search_group_screen.dart';
import 'package:genchi_app/screens/search_tasks_screen.dart';
import 'package:genchi_app/screens/splash_screen.dart';
import 'package:genchi_app/screens/task_screen.dart';
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
import 'package:genchi_app/services/notification_service.dart';
import 'package:genchi_app/services/task_service.dart';

import 'services/authentication_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:provider/provider.dart';

//TODO go through components and turn them into widgets rather than classes (builder function is heavy)
void main() {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(Genchi());
}

class Genchi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //TODO: add in state provider for bottom sheet.
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
}

class StartUp extends StatelessWidget {
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
                hintColor: Colors.black45),
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
              TaskScreen.id: (context) => TaskScreen(),
              EditTaskScreen.id: (context) => EditTaskScreen(),
              TestScreen.id: (context) => TestScreen(),
              ApplicationChatScreen.id: (context) => ApplicationChatScreen(),
              SearchTasksScreen.id: (context) => SearchTasksScreen(),
              OnboardingScreen.id: (context) => OnboardingScreen(),
              EditAccountSettingsScreen.id: (context) =>
                  EditAccountSettingsScreen(),
              UserScreen.id: (context) => UserScreen(),
            },
          );
        }

        /// The async function is still loading
        return SplashScreen();
      },
    );
  }
}
