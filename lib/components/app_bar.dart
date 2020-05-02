import 'package:flutter/material.dart';


//ToDo: create the app bar into a silverappbar
class MyAppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppNavigationBar({@required this.barTitle});

  final String barTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        barTitle,
        style: TextStyle(
          fontSize: 30,
        ),
      ),
      backgroundColor: Colors.lightBlueAccent,
      elevation: 0.0,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
