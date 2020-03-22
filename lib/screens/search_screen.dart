import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text("Search"),
            border: Border.all(width:0.0),
          ),
          child: Center(
            child: Text(
              "This is the search page",
              style: CupertinoTheme.of(context).textTheme.actionTextStyle,
            ),
          ),
        );
      },
    );
  }
}
