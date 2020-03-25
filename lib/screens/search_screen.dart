import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'search_screen2.dart';
import 'package:genchi_app/components/app_bar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      routes: {
        SecondSearchScreen.id : (context) => SecondSearchScreen(),
      },
      builder: (context) {
        return Scaffold(
          appBar: AppNavigationBar(barTitle: "Search"),
          body: Center(
            child: RoundedButton(
              buttonColor: Colors.blueAccent,
              buttonTitle: "Screen 2",
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return SecondSearchScreen();
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

