import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'search_screen2.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {

        //ToDo: Turn into normal scaffold
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("Search"),
            border: Border.all(width: 0.0),
          ),
          child: Center(
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
