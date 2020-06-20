import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';

import 'package:genchi_app/screens/favourites_screen.dart';
import 'package:genchi_app/screens/forgot_password_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/search_manual_screen.dart';
import 'package:genchi_app/screens/splash_screen.dart';
import 'package:genchi_app/screens/task_screen.dart';
import 'package:genchi_app/screens/welcome_screen.dart';
import 'package:genchi_app/screens/login_screen.dart';
import 'package:genchi_app/screens/registration_screen.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'package:genchi_app/screens/search_provider_screen.dart';
import 'package:genchi_app/screens/reg_sequence_screen.dart';
import 'package:genchi_app/screens/edit_account_screen.dart';
import 'package:genchi_app/screens/provider_screen.dart';
import 'package:genchi_app/screens/edit_provider_account_screen.dart';
import 'package:genchi_app/screens/about_screen.dart';
import 'package:genchi_app/screens/post_task_screen.dart';
import 'package:genchi_app/services/task_service.dart';

import 'services/provider_service.dart';
import 'services/authentication_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


import 'package:provider/provider.dart';

//TODO go through components and turn them into widgets rather than classes (builder function is heavy)
//TODO all my futures are wrong! PLEASE FIX THEM ASAP
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
        ChangeNotifierProvider(create: (_) => AuthenticationService()),
        ChangeNotifierProvider(create: (_) => ProviderService()),
        ChangeNotifierProvider(create: (_) => TaskService()),
      ],
      child: StartUp(),
    );
  }
}

class StartUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthenticationService>(context, listen: false)
          .isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool loggedIn = snapshot.data;
          return MaterialApp(
            theme: ThemeData(
              fontFamily: 'FuturaPT',
              canvasColor: Color(kGenchiCream),
              scaffoldBackgroundColor: Colors.white,
              indicatorColor: Color(kGenchiOrange),
            ),
            initialRoute: loggedIn ? HomeScreen.id : WelcomeScreen.id,
            routes: {
              WelcomeScreen.id: (context) => WelcomeScreen(),
              LoginScreen.id: (context) => LoginScreen(),
              RegistrationScreen.id: (context) => RegistrationScreen(),
              ChatScreen.id: (context) => ChatScreen(),
              HomeScreen.id: (context) => HomeScreen(),
              RegSequenceScreen.id: (context) => RegSequenceScreen(),
              EditAccountScreen.id: (context) => EditAccountScreen(),
              ForgotPasswordScreen.id: (context) => ForgotPasswordScreen(),
              ProviderScreen.id: (context) => ProviderScreen(),
              SearchProviderScreen.id: (context) => SearchProviderScreen(),
              EditProviderAccountScreen.id: (context) =>
                  EditProviderAccountScreen(),
              FavouritesScreen.id: (context) => FavouritesScreen(),
              AboutScreen.id: (context) => AboutScreen(),
              SearchManualScreen.id: (context) => SearchManualScreen(),
              PostTaskScreen.id: (context) => PostTaskScreen(),
              TaskScreen.id: (context) => TaskScreen(),
              EditTaskScreen.id: (context) => EditTaskScreen(),
            },
          );
        }

        /// The async function is still loading
        return SplashScreen();
      },
    );
  }
}
