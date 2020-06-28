import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/screens/post_task_screen.dart';
import 'package:genchi_app/screens/welcome_screen.dart';
import 'package:genchi_app/screens/edit_account_screen.dart';
import 'package:genchi_app/screens/provider_screen.dart';
import 'package:genchi_app/screens/favourites_screen.dart';
import 'package:genchi_app/screens/about_screen.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_option_tile.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/provider_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName;
  List<ProviderUser> providers;

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  Widget build(BuildContext context) {
    print('Profile screen: activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    final providerService = Provider.of<ProviderService>(context);

    User currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: currentUser.name ?? "Profile"),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('images/Logo_Clear.png'),
            alignment: Alignment(2.5,1.2),
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Center(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            children: <Widget>[
              DisplayPicture(
                imageUrl: currentUser.displayPictureURL,
                height: 0.25,
                border: true,
              ),
              SizedBox(height: 5),
//              ProfileOptionTile(
//                text: 'Crash',
//                onPressed: () {
//                throw Exception('ERORRRORR');
//                },
//              ),
//              ProfileOptionTile(
//                text: 'Post Task',
//                onPressed: () async {
//                  bool createAccount = await showYesNoAlert(
//                      context: context, title: 'Post task?');
//                  if (createAccount)
//                    Navigator.pushNamed(context, PostTaskScreen.id);
//                },
//              ),
              if (userIsProvider)
                ProfileOptionTile(
                  text: 'Provider Accounts',
                  isPressable: false,
                  onPressed: () {},
                ),
              if (userIsProvider) Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: FutureBuilder(
                    //This function returns a list of providerUsers
                    future: firestoreAPI.getProviders(
                        pids: currentUser.providerProfiles),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgress();
                      }
                      final List<ProviderUser> providers = snapshot.data;

                      List<Widget> providerCards = [];

                      for (ProviderUser provider in providers) {
                        Widget pCard = ProviderAccountCard(
                            height: (MediaQuery.of(context).size.height * 0.1),
                            provider: provider,
                            onPressed: () async {
                              await providerService.updateCurrentProvider(provider.pid);
                              Navigator.pushNamed(context, ProviderScreen.id, arguments: ProviderScreenArguments(provider: provider));
                            });
                        providerCards.add(pCard);
                      }

                      ///add the "add provider" card
                      providerCards.add(
                        AddProviderCard(
                            height: (MediaQuery.of(context).size.height * 0.1),
                            onPressed: () async {
                              bool createAccount = await showYesNoAlert(
                                  context: context,
                                  title: 'Create Provider Account?',
                                  body:
                                  "Are you ready to provide your skills to the Cambridge community?");
                              if (createAccount) {
                                DocumentReference result = await firestoreAPI.addProvider(
                                    ProviderUser(
                                        uid: authProvider.currentUser.id,
                                        displayPictureURL: currentUser.displayPictureURL,
                                        displayPictureFileName:
                                        currentUser.displayPictureFileName),
                                    authProvider.currentUser.id);
                                await authProvider.updateCurrentUserData();

                                await providerService
                                    .updateCurrentProvider(result.documentID);

                                Navigator.pushNamed(context, ProviderScreen.id,
                                    arguments: ProviderScreenArguments(
                                        provider: providerService.currentProvider));
                              }
                            },

                        ),
                      );

                      //TODO come back to formatting
                      return Container(
                        height: 100,
                        child: ListView(
                        padding: EdgeInsets.fromLTRB(20,0,0,0),
                          scrollDirection: Axis.horizontal,
                          children: providerCards,
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.black,
                ),
              ),
              if(!userIsProvider) ProfileOptionTile (
                text: 'Create Provider Profile',
                onPressed: () async {
                  bool createAccount = await showYesNoAlert(
                      context: context,
                      title: 'Create Provider Account?',
                      body: "Are you ready to provide your skills to the Cambridge community?");
                  if (createAccount) {
                    DocumentReference result = await firestoreAPI.addProvider(
                        ProviderUser(
                            uid: authProvider.currentUser.id,
                            displayPictureURL: currentUser.displayPictureURL,
                            displayPictureFileName:
                                currentUser.displayPictureFileName),
                        authProvider.currentUser.id);
                    await authProvider.updateCurrentUserData();

                    await providerService
                        .updateCurrentProvider(result.documentID);

                    Navigator.pushNamed(context, ProviderScreen.id,
                        arguments: ProviderScreenArguments(
                            provider: providerService.currentProvider));
                  }
                },
              ),
              ProfileOptionTile(
                text: 'Favourites',
                onPressed: () {
                  Navigator.pushNamed(context, FavouritesScreen.id);
                },
              ),
              ProfileOptionTile(
                text: 'Account Settings',
                onPressed: () {
                  Navigator.pushNamed(context, EditAccountScreen.id);
                },
              ),
              ProfileOptionTile(
                text: 'About Genchi',
                onPressed: () {
                  Navigator.pushNamed(context, AboutScreen.id);
                },
              ),
              ProfileOptionTile(
                text: 'Log Out',
                onPressed: () {
                  Platform.isIOS
                      ? showAlertIOS(
                          context: context,
                          actionFunction: () async {
                            await authProvider.signUserOut();
                            Navigator.of(context, rootNavigator: true)
                                .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                    (Route<dynamic> route) => false);
                          },
                          alertMessage: "Log out")
                      : showAlertAndroid(
                          context: context,
                          actionFunction: () async {
                            await authProvider.signUserOut();
                            Navigator.of(context, rootNavigator: true)
                                .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                    (Route<dynamic> route) => false);
                          },
                          alertMessage: "Log out");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
