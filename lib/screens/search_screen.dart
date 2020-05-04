import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'search_screen2.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/components/profile_card.dart';
import 'package:genchi_app/models/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<User> users;
  List<ProviderUser> providers;

  final messageTextController = TextEditingController();

  final FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(kGenchiCream),
      appBar: MyAppNavigationBar(barTitle: "Search"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Grabs all users from firestore
          Text("Showing all registered users:"),
          Container(
            child: StreamBuilder(
              stream: firestoreAPI.fetchUsersAsStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  //Todo: this line throwing error when timestamp available - see Flutter Socail
                  users = snapshot.data.documents.map((doc) => User.fromMap(doc.data)).toList();

                  return Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (buildContext, index) =>
                          ProfileCard(userDetails: users[index]),
                    ),
                  );
                } else {
                  return Text('fetching');
                }
              },
            ),
          ),
          Text("Showing all registered providers:"),
          Container(
            child: StreamBuilder(
              stream: firestoreAPI.fetchProvidersAsStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  //Todo: this line throwing error when timestamp available - see Flutter Socail
                  providers = snapshot.data.documents.map((doc) => ProviderUser.fromMap(doc.data)).toList();

                  return Expanded(
                    child: ListView.builder(
                      itemCount: providers.length,
                      itemBuilder: (buildContext, index) =>
                          ProviderCard(providerDetails: providers[index]),
                    ),
                  );
                } else {
                  return Text('fetching');
                }
              },
            ),
          ),
          RoundedButton(
            buttonColor: Colors.blueAccent,
            buttonTitle: "Screen 2",
            onPressed: () {
              Navigator.pushNamed(context, SecondSearchScreen.id);
            },
          ),
          Container(
            height: 100.0,
          )
        ],
      ),
    );
  }
}
