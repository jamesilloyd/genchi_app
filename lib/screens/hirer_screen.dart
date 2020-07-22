import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/hirer_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HirerScreen extends StatefulWidget {
  static const id = 'hirer_screen';

  @override
  _HirerScreenState createState() => _HirerScreenState();
}

class _HirerScreenState extends State<HirerScreen> {


  Widget buildFurtherLinkSection({User currentHirer}) {
    List<Widget> widgets = [];

    print(currentHirer.url1['link']);

    print(currentHirer.url1['desc']);

    if ((currentHirer.url1['link'] != '') || (currentHirer.url2['link'] != '')) {
      widgets.addAll([
        Container(
          child: Text(
            "Website Links",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 5)
      ]);


      if (currentHirer.url1['link'] != '') {
        widgets.addAll([
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: currentHirer.url1['desc'],
                  style: TextStyle(color: Colors.blue,fontFamily: 'FuturaPT', fontSize: 16),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(currentHirer.url1['link']);
                    })
            ]),
          ),
          SizedBox(
            height: 10,
          )
        ]);
      }
      if (currentHirer.url1['link'] != '') {
        widgets.addAll([
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: currentHirer.url2['desc'],
                  style: TextStyle(color: Colors.blue,fontFamily: 'FuturaPT', fontSize: 16),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(currentHirer.url2['link']);
                    })
            ]),
          )
        ]);
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }


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
              style: TextStyle(fontSize: 16.0),
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
              ),
            ),
            SizedBox(height: 10),
            buildFurtherLinkSection(currentHirer: hirer),
          ],
        ),
      ),
    );
  }
}
