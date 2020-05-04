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
import 'models/authentication.dart';
import 'screens/edit_account_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/provider_screen.dart';
import 'screens/create_provider_screen.dart';

void main() {
  runApp(Genchi());
}

class Genchi extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //ToDo to be updated (1)
    providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationService()),
      ],
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'FuturaPT'),
        //ToDo: need to implement correct start up logic
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
          SplashScreen.id : (context) => SplashScreen(),
          EditAccountScreen.id : (context) => EditAccountScreen(),
          ForgotPasswordScreen.id : (context) => ForgotPasswordScreen(),
          ProviderScreen.id : (context) => ProviderScreen(),
          CreateProviderScreen.id : (context) => CreateProviderScreen(),

        },
      ),
    );
  }
}
