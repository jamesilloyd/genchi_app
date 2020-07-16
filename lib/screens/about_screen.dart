import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_option_tile.dart';
import 'package:genchi_app/main.dart';

import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  static const id = 'about_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppNavigationBar(
        barTitle: 'About Genchi',
      ),
      body: ListView(
//        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0,15,0,0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              child: Image.asset('images/Logo_Clear.png'),
            ),
          ),

          ProfileOptionTile(
            text: 'About Us',
            onPressed: () async {
              if (await canLaunch(GenchiAboutURL)) {
                await launch(GenchiAboutURL);
              } else {
                print("Could not open URL");
              }
            },
          ),
          ProfileOptionTile(
            text: 'What is a Provider?',
            onPressed: () async {
              if (await canLaunch(GenchiProviderURL)) {
                await launch(GenchiProviderURL);
              } else {
                print("Could not open URL");
              }
            },
          ),
          ProfileOptionTile(
            text: 'What is a Hirer?',
            onPressed: () async {
              if (await canLaunch(GenchiHirerURL)) {
                await launch(GenchiHirerURL);
              } else {
                print("Could not open URL");
              }
            },
          ),
          ProfileOptionTile(
            text: 'Other FAQs',
            onPressed: () async {
              if (await canLaunch(GenchiFAQsURL)) {
                await launch(GenchiFAQsURL);
              } else {
                print("Could not open URL");
              }
            },
          ),
          ProfileOptionTile(
            text: 'T&Cs',
            onPressed: () async {
              if (await canLaunch(GenchiTACsURL)) {
                await launch(GenchiTACsURL);
              } else {
                print("Could not open URL");
              }
            },
          ),
          ProfileOptionTile(
            text: 'Privacy Policy',
            onPressed: () async {
              if (await canLaunch(GenchiPPURL)) {
                await launch(GenchiPPURL);
              } else {
                print("Could not open URL");
              }
            },
          ),
          ProfileOptionTile(
            text: 'Genchi Facebook Page',
            onPressed: () async {
              if (await canLaunch(GenchiFacebookURL)) {
                await launch(GenchiFacebookURL);
              } else {
                print("Could not open URL");
              }
            },
          )
        ],
      ),
    );
  }
}
