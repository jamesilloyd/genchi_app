import 'dart:io' as io;
import 'dart:io' show Platform;

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

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

User currentUser;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  io.File _image;
  String userName;
  List<ProviderUser> providers;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        _image = image;
      },
    );
  }

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
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                height: MediaQuery.of(context).size.height * 0.2,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Center(
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage("images/Logo_Clear.png"),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
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
                    ),
                  ],
                ),
              FutureBuilder(
                  //This function returns a list of providerUsers
                  future: getUsersProviders(currentUser.providerProfiles),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      //ToDo: Add in progressmodalhud
                      return Text("Loading Provider Accounts");
                    }
                    final List<ProviderUser> providers = snapshot.data;

                    List<ProviderCard> providerCards = [];

                    for (ProviderUser provider in providers) {
                      ProviderCard pCard = ProviderCard(
                        //ToDo: implement dp
                        image: AssetImage("images/Logo_Clear.png"),
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
              ProfileOptionTile(
                text: userIsProvider ? 'Create Another Provider Account':'Create Provider Profile',
                onPressed: () async {
                  DocumentReference result = await firestoreAPI.addProvider(
                      ProviderUser(uid: authProvider.currentUser.id),
                      authProvider.currentUser.id);
                  await authProvider.updateCurrentUserData();

                  await providerService.updateCurrentProvider(result.documentID);

                  Navigator.pushNamed(context, ProviderScreen.id,
                      arguments: ProviderScreenArguments(
                          provider: providerService.currentProvider));
                },
              ),
              ProfileOptionTile(
                text: 'Change Details',
                onPressed: () {
                  Navigator.pushNamed(context, EditAccountScreen.id);
                },
              ),
              ProfileOptionTile(
                  text: 'About Genchi',
                  onPressed: () async {
                    if (await canLaunch(GenchiAboutURL)) {
                      await launch(GenchiAboutURL);
                    } else {
                      print("Could not open URL");
                    }
                  }),
              ProfileOptionTile(
                text: 'Log Out',
                onPressed: () {
                  Platform.isIOS
                      ? showAlertIOS(context, () {
                          authProvider.signUserOut();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                  (Route<dynamic> route) => false);
                        }, "Log out")
                      : showAlertAndroid(context, () {
                          authProvider.signUserOut();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(WelcomeScreen.id,
                                  (Route<dynamic> route) => false);
                        }, "Log out");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
