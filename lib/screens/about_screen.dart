import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_option_tile.dart';

import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  static const id = 'about_screen';
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    print('About screen activated');
    return Scaffold(
      appBar: BasicAppNavigationBar(
        barTitle: 'About Genchi',
      ),
      body: ListView(
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
              analytics.logEvent(name: 'about_genchi_url_pressed');
              if (await canLaunch(GenchiURL)) {
                await launch(GenchiURL);
              } else {
                print("Could not open URL");
              }
            },
          ),
          ProfileOptionTile(
            text: 'T&Cs',
            onPressed: () async {
              analytics.logEvent(name: 'TaCs_url_pressed');
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
              analytics.logEvent(name: 'privacy_policy_url_pressed');
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
              analytics.logEvent(name: 'genchi_facebook_page_url_pressed');
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
