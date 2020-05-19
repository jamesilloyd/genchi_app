import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'welcome_screen.dart';
import 'edit_account_screen.dart';
import 'provider_screen.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_option_tile.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/create_provider_alert.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


User currentUser;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String userName;
  List<ProviderUser> providers;


  final FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  //ToDo: this can all go into CRUDModel
  Future<List<ProviderUser>> getUsersProviders(usersPids) async {
    List<ProviderUser> providers = [];
    for (var pid in usersPids) {
      providers.add(await firestoreAPI.getProviderById(pid));
    }
    return providers;
  }


  @override
  Widget build(BuildContext context) {

    print('Profile screen activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    final providerService = Provider.of<ProviderService>(context);

    User currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: currentUser.name ?? "Profile"),
      body: Container(
        color: Colors.white,
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              DisplayPicture(imageUrl: currentUser.displayPictureURL, height: 0.25,),
              SizedBox(height:20),
              Divider(
                height: 0,
              ),
              if (userIsProvider)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Your Provider Accounts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(kGenchiBlue),
                            fontWeight: FontWeight.w400,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 0,
//                      color: Color(kGenchiBlue),
                    ),
                  ],
                ),
              FutureBuilder(
                  //This function returns a list of providerUsers
                  future: getUsersProviders(currentUser.providerProfiles),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {

                      return CircularProgress();
                    }
                    final List<ProviderUser> providers = snapshot.data;

                    List<ProviderCard> providerCards = [];

                    for (ProviderUser provider in providers) {
                      ProviderCard pCard = ProviderCard(
                        //ToDo: implement dp
                        image: provider.displayPictureURL == null ? AssetImage("images/Logo_Clear.png") : CachedNetworkImageProvider(provider.displayPictureURL),
                        name: provider.name,
                        description: provider.bio,
                        service: provider.type,
                        onTap: () async {

                          await providerService.updateCurrentProvider(provider.pid);
                          Navigator.pushNamed(context, ProviderScreen.id,
                              arguments:
                                  ProviderScreenArguments(provider: provider));
                        },
                      );

                      providerCards.add(pCard);
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: providerCards,
                    );
                  },),

              //TODO: Add in some feedback here
              ProfileOptionTile(
                text: userIsProvider ? 'Provide Another Service':'Create Provider Profile',
                onPressed: () async {

                  bool createAccount = await showProviderAlert(context: context);
                  if(createAccount){
                    DocumentReference result = await firestoreAPI.addProvider(
                        ProviderUser(uid: authProvider.currentUser.id),
                        authProvider.currentUser.id);
                    await authProvider.updateCurrentUserData();

                    await providerService.updateCurrentProvider(result.documentID);

                    Navigator.pushNamed(context, ProviderScreen.id,
                        arguments: ProviderScreenArguments(
                            provider: providerService.currentProvider));
                  }
                },
              ),
              ProfileOptionTile(
                text: 'Change Details',
                onPressed: () {
                  Navigator.pushNamed(context, EditAccountScreen.id);
                },
              ),

              //TODO: open up another page that gives a brief overview, find out more and links to pp and tcs
              ProfileOptionTile(
                  text: 'About Genchi',
                  onPressed: () async {
                    if (await canLaunch(GenchiURL)) {
                      await launch(GenchiURL);
                    } else {
                      print("Could not open URL");
                    }
                  }),
              ProfileOptionTile(
                text: 'Log Out',
                onPressed: () {
                  Platform.isIOS
                      ? showAlertIOS(context: context, actionFunction: () async {
                          await authProvider.signUserOut();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                  (Route<dynamic> route) => false);
                        }, alertMessage: "Log out")
                      : showAlertAndroid(context: context,actionFunction: () async {
                          await authProvider.signUserOut();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                  (Route<dynamic> route) => false);
                        }, alertMessage: "Log out");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
