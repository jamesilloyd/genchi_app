import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';
import 'package:google_fonts/google_fonts.dart';



class MyAppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppNavigationBar({@required this.barTitle});

  final String barTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        barTitle,
      ),
      backgroundColor: Color(kGenchiCream),
      elevation: 2.0,
    );
//    style: GoogleFonts.helvetica
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
