import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/screens/forgot_password_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/welcome_screen.dart';
import 'package:genchi_app/screens/login_screen.dart';
import 'package:genchi_app/screens/registration_screen.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'screens/search_provider_screen.dart';
import 'screens/reg_sequence_screen.dart';
import 'package:provider/provider.dart';
import 'models/authentication.dart';
import 'screens/edit_account_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/provider_screen.dart';
import 'package:genchi_app/screens/edit_provider_account_screen.dart';

void main() {
  runApp(Genchi());
}

class Genchi extends StatelessWidget {

  //TODO: how to add images with correct resolutions (do we need to add three) - looks very granular on the app

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //ToDo to be updated (1)
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationService()),
        ChangeNotifierProvider(create: (_) => ProviderService()),
      ],
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'FuturaPT'),
        //ToDo: need to implement correct start up logic
        home: WelcomeScreen(),
        initialRoute: WelcomeScreen.id,
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
          EditProviderAccountScreen.id: (context) => EditProviderAccountScreen(),
        },
      ),
    );
  }
}
