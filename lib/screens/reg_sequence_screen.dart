import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

import 'package:genchi_app/screens/edit_provider_account_screen.dart';
import 'home_screen.dart';
import 'edit_provider_account_screen.dart';

import 'package:genchi_app/components/platform_alerts.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/user.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/provider_service.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegSequenceScreen extends StatefulWidget {
  static const String id = "reg_sequence_screen";

  @override
  _RegSequenceScreenState createState() => _RegSequenceScreenState();
}

//TODO link or popup box about what each one is?
//TODO This 100% needs to be in the form of a popup
class _RegSequenceScreenState extends State<RegSequenceScreen> {
  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  Widget build(BuildContext context) {
    AuthenticationService authProvider =
        Provider.of<AuthenticationService>(context);
    ProviderService providerService = Provider.of<ProviderService>(context);

    return Scaffold(
      backgroundColor: Color(kGenchiGreen),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.05,
            MediaQuery.of(context).size.height * 0.05,
            MediaQuery.of(context).size.width * 0.05,
            MediaQuery.of(context).size.height * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Color(kGenchiGreen),
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "WHAT BRINGS YOU TO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(kGenchiCream),
                      fontSize: 40.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Hero(
                      tag: 'logo',
                      child: Container(
                        child: Image.asset('images/LogoAndName.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.425,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: RaisedButton(
                          color: Color(kGenchiOrange),
                          onPressed: () async {
                            bool createHirer = await showYesNoAlert(
                                context: context,
                                title: 'Create Hirer Account?',
                                body:
                                    "Are you ready to hire students with skills in the Cambridge community?");
                            if (createHirer) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  HomeScreen.id,
                                  (Route<dynamic> route) => false);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Hire",
                                      style: TextStyle(
                                        color: Color(kGenchiBlue),
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                    child: Image.asset('images/hirer.png',
                                        fit: BoxFit.contain)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.05,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.425,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: RaisedButton(
                          color: Color(kGenchiBlue),
                          onPressed: () async {
                            bool createProvider = await showYesNoAlert(
                                context: context,
                                title: 'Create Provider Account',
                                body: "Are you ready to provide your skills to the Cambridge community?");
                            if (createProvider) {
                              DocumentReference result =
                                  await firestoreAPI.addProvider(
                                      ProviderUser(
                                          uid: authProvider.currentUser.id),
                                      authProvider.currentUser.id);
                              await authProvider.updateCurrentUserData();

                              ProviderUser newProvider = await firestoreAPI
                                  .getProviderById(result.documentID);
                              await providerService
                                  .updateCurrentProvider(result.documentID);

                              print(newProvider);

                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  EditProviderAccountScreen.id,
                                  (Route<dynamic> route) => false,
                                  arguments: EditProviderAccountScreenArguments(
                                      fromRegistration: true,
                                      provider: newProvider));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Provide",
                                      style: TextStyle(
                                        color: Color(kGenchiOrange),
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                    child: Image.asset('images/provider.png',
                                        fit: BoxFit.contain)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
