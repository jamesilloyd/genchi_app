import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/user.dart';
import 'home_screen.dart';

class CreateProviderScreen extends StatefulWidget {
  static const String id = 'create_provider_screen';
  @override
  _CreateProviderScreenState createState() => _CreateProviderScreenState();
}

class _CreateProviderScreenState extends State<CreateProviderScreen> {
  String name;
  String bio;
  String type;

  @override
  Widget build(BuildContext context) {
    final firestoreProvider = Provider.of<FirestoreCRUDModel>(context);
    final authProvider = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: MyAppNavigationBar(
        barTitle: "Create Provider",
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 48.0,
            ),
            TextField(
              textAlign: TextAlign.center,
              onChanged: (value) {
                //Do something with the user input.
                name = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: "Enter provider name"),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  bio = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "Enter description")),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  type = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "Enter provider type")),
            SizedBox(
              height: 20.0,
            ),
            RoundedButton(
              buttonColor: Colors.lightBlue,
              buttonTitle: "Create Provider Profile",
              onPressed: () async {
                //ToDo: this is working, need to put in error handling
                await firestoreProvider.addProvider(
                  ProviderUser(
                    uid: authProvider.currentUser.id,
                    name: name,
                    bio: bio,
                    type: type,
                  ),
                ).then((docRef) async {
                  await firestoreProvider.updateProvider(ProviderUser(pid: docRef.documentID), docRef.documentID);
                  //ToDo: change this so that the provider id is appended to the list rather than creating a new list
                  await firestoreProvider.updateUser(User(providerProfiles: [docRef.documentID]), authProvider.currentUser.id);
                } );
                //ToDo: how to go back to home screen with specific index
                Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id,
                        (Route<dynamic> route) => false);
              },
            )
          ],
        ),
      ),
    );
  }
}
