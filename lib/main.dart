import 'package:flutter/material.dart';
import 'package:genchi_app/screens/forgot_password_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/search_screen2.dart';
import 'package:genchi_app/screens/splash_screen.dart';
import 'package:genchi_app/screens/welcome_screen.dart';
import 'package:genchi_app/screens/login_screen.dart';
import 'package:genchi_app/screens/registration_screen.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'screens/profile_screen2.dart';
import 'screens/reg_sequence_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'locator.dart';
import 'models/CRUDModel.dart';
import 'models/authentication.dart';
import 'screens/edit_account_screen.dart';
import 'screens/forgot_password_screen.dart';


void main() {
  setupLocator();
  runApp(Genchi());
}

class Genchi extends StatelessWidget {

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //ToDo: I'm worried this is a very  large changenotifierprovider, may need to break up into smaller components
        ChangeNotifierProvider(create: (_) => locator<FirebaseCRUDModel>()),
        ChangeNotifierProvider(create: (_) => locator<AuthenticationService>()),
      ],
      child: MaterialApp(
        home: WelcomeScreen(),
//        initialRoute: isUserAlreadyLoggedIn() ? HomeScreen.id : WelcomeScreen.id ,
      //ToDo: one option is to write the data to disk if the user is logged in or not, use this data to choose launch screen
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id : (context) => WelcomeScreen(),
          LoginScreen.id : (context) => LoginScreen(),
          RegistrationScreen.id : (context) => RegistrationScreen(),
          ChatScreen.id : (context) => ChatScreen(),
          HomeScreen.id : (context) => HomeScreen(),
          SecondProfileScreen.id : (context) => SecondProfileScreen(),
          RegSequenceScreen.id : (context) => RegSequenceScreen(),
          SecondSearchScreen.id : (context) => SecondSearchScreen(),
          SplashScreen.id : (context) => SplashScreen(),
          EditAccountScreen.id : (context) => EditAccountScreen(),
          ForgotPasswordScreen.id : (context) => ForgotPasswordScreen(),

        },
      ),
    );
  }
}
