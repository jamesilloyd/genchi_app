import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';



class FavouritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: 'Favourites',),
      body: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 30,
            color: Color(kGenchiBlue),
          ),
        ),
      ),
    );
  }
}
