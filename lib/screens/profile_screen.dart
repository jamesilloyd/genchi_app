import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'profile_screen2.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
        routes: {
          SecondProfileScreen.id: (context) => SecondProfileScreen(),
          WelcomeScreen.id : (context) => WelcomeScreen(),
        },

        builder: (context) {
          return Scaffold(
            appBar: AppNavigationBar(barTitle: "Profile"),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RoundedButton(
                        buttonColor: Colors.blueAccent,
                        buttonTitle: "Screen 2",
                        onPressed: () {
                          Navigator.pushNamed(context, SecondProfileScreen.id);

//                          Navigator.of(context).push(
//                            CupertinoPageRoute(
//                              builder: (context) {
//                                return SecondProfileScreen();
//                              },
//                            ),
//                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
