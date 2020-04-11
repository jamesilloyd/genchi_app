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
import 'package:genchi_app/models/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'locator.dart';
import 'models/CRUDModel.dart';

void main() => runApp(Genchi());

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
        ChangeNotifierProvider<Profile>(create: (_) => Profile()),
        ChangeNotifierProvider(create: (_) => locator<CRUDModel>()),
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
