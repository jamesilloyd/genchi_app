import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/search_group_screen.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'search_provider_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<GenchiUser> users;
  List<GenchiUser> serviceProviders;

  static final FirebaseAnalytics analytics = FirebaseAnalytics();

  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;
  bool showServiceProviders = false;
  String filter = 'GROUPS';

  Map<String, Future> serviceFutures = {};

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: 'home/search_screen');
  }

  @override
  Widget build(BuildContext context) {
    if (debugMode) print('Search screen activated');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgress(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: BasicAppNavigationBar(
            barTitle: 'Search',
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              children: <Widget>[
                SizedBox(height: 20),
                SizedBox(
                  height: 140,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: filter == 'GROUPS' ? 100 : 80,
                                width: filter == 'GROUPS' ? 100 : 80,
                                decoration: filter == 'GROUPS'
                                    ? BoxDecoration(
                                        color: Color(kGenchiLightGreen),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                      )
                                    : BoxDecoration(
                                        color: Color(kGenchiLightOrange),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                      ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: Icon(
                                      Icons.group,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'GROUPS',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: filter == 'GROUPS'
                                      ? Colors.black
                                      : Colors.black45,
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            filter = 'GROUPS';
                            setState(() {});
                          },
                        ),
                        GestureDetector(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: filter == 'INDIVIDUALS' ? 100 : 80,
                                width: filter == 'INDIVIDUALS' ? 100 : 80,
                                decoration: filter == 'INDIVIDUALS'
                                    ? BoxDecoration(
                                        color: Color(kGenchiLightGreen),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                      )
                                    : BoxDecoration(
                                        color: Color(kGenchiLightOrange),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                      ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Image(
                                    image: AssetImage('images/individual.png'),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'INDIVIDUALS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: filter == 'INDIVIDUALS'
                                      ? Colors.black
                                      : Colors.black45,
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            filter = 'INDIVIDUALS';
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'CATEGORIES',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400
                  ),
                ),
                Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 20,
                ),
                AnimatedCrossFade(
                  crossFadeState: filter == 'GROUPS'
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 300),
                  firstChild: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    childAspectRatio: 1.618,
                    children: List.generate(
                      groupsList.length,
                      (index) {
                        GroupType groupType;

                        groupType = groupsList[index];

                        return SearchServiceTile(
                          onPressed: () {
                            FirebaseAnalytics().logEvent(
                                name: 'search_button_clicked_for_${groupType.databaseValue.replaceAll(' ', '')}');

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SearchGroupScreen(groupType: groupType)));
                          },
                          buttonTitle: groupType.namePlural,
                          imageAddress: groupType.imageAddress,
                          width: (MediaQuery.of(context).size.width - 50) / 2,
                        );
                      },
                    ),
                  ),
                  secondChild: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    childAspectRatio: 1.618,
                    children: List.generate(
                      servicesList.length,
                      (index) {
                        Service service;

                        service = servicesList[index];

                        return SearchServiceTile(
                          onPressed: () {
                            FirebaseAnalytics().logEvent(
                                name: 'search_button_clicked_for_${service.databaseValue.replaceAll(' ', '')}');

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SearchProviderScreen(service: service)));
                          },
                          buttonTitle: service.namePlural,
                          imageAddress: service.imageAddress,
                          width: (MediaQuery.of(context).size.width - 50) / 2,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
