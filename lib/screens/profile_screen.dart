import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/edit_account_settings_screen.dart';
import 'package:genchi_app/screens/edit_provider_account_screen.dart';
import 'package:genchi_app/screens/test_screen.dart';
import 'package:genchi_app/screens/user_screen.dart';

import 'package:genchi_app/screens/welcome_screen.dart';
import 'package:genchi_app/screens/favourites_screen.dart';
import 'package:genchi_app/screens/about_screen.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_option_tile.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';

import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/account_service.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/authentication_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName;
  List<GenchiUser> serviceProviders;
  bool showSpinner = false;

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/home/profile");
  }

  @override
  Widget build(BuildContext context) {
    print('Profile screen: activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    final accountService = Provider.of<AccountService>(context);

    GenchiUser currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(0, 1.14),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.29,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('images/Logo_Clear.png'),
                alignment: Alignment(1.3, 0),
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), BlendMode.dstATop),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar:
              BasicAppNavigationBar(barTitle: currentUser.name ?? "Profile"),
          backgroundColor: Colors.transparent,
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: CircularProgress(),
            child: Center(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          DisplayPicture(
                            imageUrl: currentUser.displayPictureURL,
                            height: 0.25,
                          ),
                          Positioned(
                            right: MediaQuery.of(context).size.width / 2 -
                                MediaQuery.of(context).size.height * 0.11,
                            top: MediaQuery.of(context).size.height * 0.22,
                            child: Container(
                              height: 30,
                              width: 30,
                              padding: EdgeInsets.all(2),
                              decoration: new BoxDecoration(
                                color: Color(kGenchiCream),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Color(0xff585858), width: 2),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Center(
                                    child: Icon(
                                  Icons.remove_red_eye,
                                  size: 20,
                                  color: Color(0xff585858),
                                )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      await accountService.updateCurrentAccount(
                          id: currentUser.id);
                      Navigator.pushNamed(context, UserScreen.id);
                    },
                  ),
                 // ProfileOptionTile(
                 //   text: 'Test Screen',
                 //   onPressed: ()  {
                 //    Navigator.pushNamed(context, TestScreen.id);
                 //   },
                 // ),
                  if (userIsProvider)
                    ProfileOptionTile(
                      text: 'Service Profiles',
                      isPressable: false,
                      onPressed: () {},
                    ),
                  if (userIsProvider)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: FutureBuilder(
                        ///This function returns a list of providerUsers
                        future: firestoreAPI.getServiceProviders(
                            ids: currentUser.providerProfiles),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgress();
                          }
                          final List<GenchiUser> serviceProviders = snapshot.data;

                          List<Widget> providerCards = [];

                          for (GenchiUser serviceProvider in serviceProviders) {
                            Widget pCard = ProviderAccountCard(
                                width: (MediaQuery.of(context).size.width -
                                        20 * 3) /
                                    2.2,
                                serviceProvider: serviceProvider,
                                isSmallScreen:
                                    MediaQuery.of(context).size.height < 600,
                                onPressed: () async {
                                  await accountService.updateCurrentAccount(
                                      id: serviceProvider.id);
                                  Navigator.pushNamed(context, UserScreen.id);
                                });
                            providerCards.add(pCard);
                          }

                          ///add the "add provider" card
                          providerCards.add(
                            AddProviderCard(
                              width:
                                  (MediaQuery.of(context).size.width - 20 * 3) /
                                      2.2,
                              onPressed: () async {
                                bool createAccount = await showYesNoAlert(
                                    context: context,
                                    title: 'Create Service Account?',
                                    body:
                                        "Are you ready to provide your skills to the Cambridge community?");
                                if (createAccount) {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  ///Log event in firebase
                                  await analytics.logEvent(
                                      name: 'provider_account_created');

                                  DocumentReference result =
                                      await firestoreAPI.addServiceProvider(
                                          serviceUser: GenchiUser(
                                            name: currentUser.name,
                                            mainAccountId: currentUser.id,
                                            accountType:
                                            GenchiUser().serviceProviderAccount,
                                            displayPictureURL:
                                                currentUser.displayPictureURL,
                                            displayPictureFileName: currentUser
                                                .displayPictureFileName,
                                            fcmTokens: currentUser.fcmTokens,
                                            timeStamp: Timestamp.now(),
                                          ),
                                          uid: authProvider.currentUser.id);

                                  await authProvider.updateCurrentUserData();

                                  await accountService.updateCurrentAccount(
                                      id: result.id);
                                  setState(() {
                                    showSpinner = false;
                                  });

                                  Navigator.pushNamed(context, UserScreen.id);
                                  Navigator.pushNamed(
                                      context, EditProviderAccountScreen.id);
                                }
                              },
                            ),
                          );

                          return Container(
                            height:
                                (MediaQuery.of(context).size.width - 20 * 3) /
                                        (2.2 * 1.77) +
                                    20,
                            child: ListView(
                              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                              scrollDirection: Axis.horizontal,
                              children: providerCards,
                            ),
                          );
                        },
                      ),
                    ),
                  if (userIsProvider)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 0,
                        thickness: 1,
                        color: Colors.black,
                      ),
                    ),
                  //TODO there must be a better way of doing this than using a string
                  if (!userIsProvider &&
                      currentUser.accountType == 'Individual')
                    ProfileOptionTile(
                      text: 'Create Service Profile',
                      onPressed: () async {
                        bool createAccount = await showYesNoAlert(
                            context: context,
                            title: 'Create Service Account?',
                            body:
                                "Are you ready to provide your skills to the Cambridge community?");
                        if (createAccount) {
                          setState(() {
                            showSpinner = true;
                          });

                          ///Log event in firebase
                          await analytics.logEvent(
                              name: 'provider_account_created');

                          DocumentReference result =
                              await firestoreAPI.addServiceProvider(
                                  serviceUser: GenchiUser(
                                    name: currentUser.name,
                                    mainAccountId: currentUser.id,
                                    accountType: GenchiUser().serviceProviderAccount,
                                    displayPictureURL:
                                        currentUser.displayPictureURL,
                                    displayPictureFileName:
                                        currentUser.displayPictureFileName,
                                    fcmTokens: currentUser.fcmTokens,
                                    timeStamp: Timestamp.now(),
                                  ),
                                  uid: authProvider.currentUser.id);

                          await authProvider.updateCurrentUserData();

                          await accountService.updateCurrentAccount(
                              id: result.id);
                          setState(() {
                            showSpinner = false;
                          });

                          Navigator.pushNamed(context, UserScreen.id);
                          Navigator.pushNamed(
                              context, EditProviderAccountScreen.id);
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
                      Navigator.pushNamed(
                          context, EditAccountSettingsScreen.id);
                    },
                  ),
                  ProfileOptionTile(
                    text: 'About Genchi',
                    onPressed: () {
                      Navigator.pushNamed(context, AboutScreen.id);
                    },
                  ),
                  ProfileOptionTile(
                    text: 'Give Feedback',
                    onPressed: () async {
                      if (await canLaunch(GenchiFeedbackURL)) {
                        await launch(GenchiFeedbackURL);
                      } else {
                        print("Could not open URL");
                      }
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
        ),
      ],
    );
  }
}
