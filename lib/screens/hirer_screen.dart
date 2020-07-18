import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/hirer_service.dart';
import 'package:provider/provider.dart';

class HirerScreen extends StatefulWidget {
  static const id = 'hirer_screen';

  @override
  _HirerScreenState createState() => _HirerScreenState();
}

class _HirerScreenState extends State<HirerScreen> {
  @override
  Widget build(BuildContext context) {
    if (debugMode) print('Hirer screen activated');
    final hirerProvider = Provider.of<HirerService>(context);

    User hirer = hirerProvider.currentHirer;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BasicAppNavigationBar(
        barTitle: 'Hirer',
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            DisplayPicture(
              imageUrl: hirer.displayPictureURL,
              height: 0.2,
              border: true,
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                hirer.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              thickness: 1,
            ),
            Container(
              child: Text(
                "College",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              hirer.college,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                "Subject",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              hirer.subject,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                "About Me",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              hirer.bio,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
