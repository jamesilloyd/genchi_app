import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';



class MyAppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppNavigationBar({@required this.barTitle});

  final String barTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Color(kGenchiBlue),
      ),
      title: Text(
        barTitle,
        style: TextStyle(
          color: Color(kGenchiBlue),
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Color(kGenchiCream),
      elevation: 2.0,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
