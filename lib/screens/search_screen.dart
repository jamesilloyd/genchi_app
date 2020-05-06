import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/components/app_bar.dart';

import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/screen_arguments.dart';

import 'search_provider_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';



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
      appBar: MyAppNavigationBar(barTitle: "Search"),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          padding: EdgeInsets.all(20.0),
          childAspectRatio: 1.618,
          children: List.generate(servicesList.length, (index) {
            final String service = servicesList[index];
            return SearchServiceTile(
              onPressed: () {
                Navigator.pushNamed(context, SearchProviderScreen.id,arguments: ScreenArguments(service));
              },
              buttonTitle: servicesMap[service]['name'],
              icon: servicesMap[service]['icon'],
            );
          }),

//            SearchServiceTile(
//              onPressed: () {
//                Navigator.pushNamed(context, SearchProviderScreen.id);
//              },
//              buttonTitle: 'Barber',
//              icon: Icon(
//                Icons.accessible_forward,
//                size: 100,
//                color: Color(kGenchiBlue),
//              ),
//            ),
//            SearchServiceTile(
//              onPressed: () {},
//              buttonTitle: 'Photographer',
//              icon: Icon(
//                Icons.pregnant_woman,
//                size: 100,
//                color: Color(kGenchiBlue),
//              ),
//            ),
//            SearchServiceTile(
//              onPressed: () {},
//              buttonTitle: 'Other',
//              icon: Icon(
//                Icons.queue_music,
//                size: 100,
//                color: Color(kGenchiBlue),
//              ),
//            ),
//            SearchServiceTile(
//              onPressed: () {},
//              buttonTitle: 'Other',
//              icon: Icon(
//                Icons.queue_music,
//                size: 100,
//                color: Color(kGenchiBlue),
//              ),
//            ),
        ),
      ),

//      body: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: [
//          //Grabs all users from firestore
//          Text("Showing all registered users:"),
//          Container(
//            child: StreamBuilder(
//              stream: firestoreAPI.fetchUsersAsStream(),
//              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                if (snapshot.hasData) {
//                  //Todo: this line throwing error when timestamp available - see Flutter Socail
//                  users = snapshot.data.documents.map((doc) => User.fromMap(doc.data)).toList();
//
//                  return Expanded(
//                    child: ListView.builder(
//                      itemCount: users.length,
//                      itemBuilder: (buildContext, index) =>
//                          ProfileCard(userDetails: users[index]),
//                    ),
//                  );
//                } else {
//                  return Text('fetching');
//                }
//              },
//            ),
//          ),
//          Text("Showing all registered providers:"),
//          Container(
//            child: StreamBuilder(
//              stream: firestoreAPI.fetchProvidersAsStream(),
//              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                if (snapshot.hasData) {
//                  //Todo: this line throwing error when timestamp available - see Flutter Socail
//                  providers = snapshot.data.documents.map((doc) => ProviderUser.fromMap(doc.data)).toList();
//
//                  return Expanded(
//                    child: ListView.builder(
//                      itemCount: providers.length,
//                      itemBuilder: (buildContext, index) =>
//                          ProviderCard(providerDetails: providers[index]),
//                    ),
//                  );
//                } else {
//                  return Text('fetching');
//                }
//              },
//            ),
//          ),
//          RoundedButton(
//            buttonColor: Colors.blueAccent,
//            buttonTitle: "Screen 2",
//            onPressed: () {
//              Navigator.pushNamed(context, SearchProviderScreen.id);
//            },
//          ),
//          Container(
//            height: 100.0,
//          )
//        ],
//      ),
    );
  }
}
