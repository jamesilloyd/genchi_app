import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'search_screen2.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/components/profile_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<User> users;
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<FirebaseCRUDModel>(context);
    return Scaffold(
      appBar: AppNavigationBar(barTitle: "Search"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Grabs all users from firestore
          Text("Showing all registered users:"),
          Container(
            child: StreamBuilder(
              stream: profileProvider.fetchUsersAsStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  //Todo: this line throwing error when timestamp available - see Flutter Socail
                  users = snapshot.data.documents
                      .map((doc) => User.fromMap(doc.data))
                      .toList();

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
          RoundedButton(
            buttonColor: Colors.blueAccent,
            buttonTitle: "Screen 2",
            onPressed: () {
              Navigator.pushNamed(context, SecondSearchScreen.id);
            },
          ),
          Container(
            height: 50.0,
          )
        ],
      ),
    );
  }
}
