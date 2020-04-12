import 'package:flutter/material.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/search_screen2.dart';
import 'package:genchi_app/screens/welcome_screen.dart';
import 'package:genchi_app/screens/login_screen.dart';
import 'package:genchi_app/screens/registration_screen.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'screens/profile_screen2.dart';
import 'screens/reg_sequence_screen.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'locator.dart';
import 'models/CRUDModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/authentication.dart';

void main() {
  setupLocator();
  runApp(Genchi());
}

class Genchi extends StatelessWidget {

  final _auth = FirebaseAuth.instance;


  //Automatic login
  //ToDo: move this into main.dart
  Future<bool> isUserAlreadyLoggedIn() async {
    try {
      final user = await _auth.currentUser();
      if(user != null){
        print("User logged in");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("isUserAlreadyLoggedIn $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //ToDo: I'm worried this is a very  large changenotifierprovider, may need to break up into smaller components
        ChangeNotifierProvider(create: (_) => locator<FirebaseCRUDModel>()),
        ChangeNotifierProvider(create: (_) => locator<AuthenticationService>()),
        //ToDo: how to do this - meant to create the current user to be accessed ANYWHERE!
//        StreamProvider<User>(create: (_) => FirebaseAuth.instance.onAuthStateChanged)
      ],
      child: MaterialApp(
        home: WelcomeScreen(),
//        initialRoute: isUserAlreadyLoggedIn() ? HomeScreen.id : WelcomeScreen.id ,
      //ToDo: write the data to disk if the user is logged in or not, use this data to choose launch screen
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
        },
      ),
    );
  }
}
