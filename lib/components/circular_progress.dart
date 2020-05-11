import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

class CircularProgress extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor:  AlwaysStoppedAnimation<Color>(Color(kGenchiOrange)),
        strokeWidth: 3.0,
      ),);
  }
}
