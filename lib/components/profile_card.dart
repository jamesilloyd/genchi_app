import 'package:flutter/material.dart';
import 'package:genchi_app/models/user.dart';
//import 'package:productapp/ui/views/productDetails.dart';


class ProfileCard extends StatelessWidget {
  final User userDetails;

  ProfileCard({@required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('${userDetails.name} - ${userDetails.email}' ),
          ],
        )
    );
  }
}

