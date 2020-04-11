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

void main() => runApp(Genchi());

class Genchi extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Profile>(
      //can provide more than one class here
      create: (context) => Profile(),
      child: MaterialApp(
        home: WelcomeScreen(),
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
