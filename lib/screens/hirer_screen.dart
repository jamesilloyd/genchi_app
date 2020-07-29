import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/hirer_service.dart';
import 'package:genchi_app/services/linkify_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HirerScreen extends StatefulWidget {
  static const id = 'hirer_screen';

  @override
  _HirerScreenState createState() => _HirerScreenState();
}

//TODO selectable linkify is not working
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
              child: SelectableText(
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
            SelectableText(
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
            Linkify(
              text: hirer.subject,
              onOpen: _onOpenLink,
              options: LinkifyOptions(humanize: false, defaultToHttps: true),
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
            Linkify(
              text: hirer.bio,
              onOpen: _onOpenLink,
              options: LinkifyOptions(humanize: false, defaultToHttps: true),
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    if (link.runtimeType == EmailElement) {
      //TODO handle email elements
    } else {
      String url = link.url.toLowerCase();
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $link';
      }
    }
  }
}
