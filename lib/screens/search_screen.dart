import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'search_provider_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

//TODO for some reason keeping the page alive is not working
//TODO can we implement pagination please!!!!
class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  List<User> users;
  List<User> serviceProviders;

  FirebaseAnalytics analytics = FirebaseAnalytics();

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  Future searchTasksFuture;

  bool showSpinner = false;
  bool showServiceProviders = false;
  String filter = 'GROUPS';

  Map<String, Future> serviceFutures = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    analytics.setCurrentScreen(screenName: 'home/search_screen');
    searchTasksFuture = firestoreAPI.fetchTasksAndHirers();
  }

  List<Widget> buildServiceTiles() {
    List<Widget> searchServiceTiles = [];

    for (Service service in servicesList) {
      Widget tile = Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: SearchServiceTile(
          onPressed: () {
            analytics.logEvent(
                name: 'search_button_clicked_for_${service.databaseValue}');
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchProviderScreen(service: service)));
          },
          buttonTitle: service.namePlural,
          imageAddress: service.imageAddress,
          width: (MediaQuery.of(context).size.width - 40) / 2.5,
        ),
      );
      searchServiceTiles.add(tile);
    }
    return searchServiceTiles;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                                height: filter == 'GROUPS' ? 90 : 80,
                                width: filter == 'GROUPS' ? 90 : 80,
                                decoration: BoxDecoration(
                                  color: Color(kGenchiLightOrange),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(45.0),
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
                                height: filter == 'INDIVIDUALS' ? 90 : 80,
                                width: filter == 'INDIVIDUALS' ? 90 : 80,
                                decoration: BoxDecoration(
                                  color: Color(kGenchiLightOrange),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(45.0),
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
                      servicesList.length,
                      (index) {
                        Service service;

                        service = servicesList[index];

                        return SearchServiceTile(
                          onPressed: () {
                            //TODO need to take spaces out of value
                            FirebaseAnalytics().logEvent(
                                name:
                                    'search_button_clicked_for_${service.databaseValue}');

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

                        service = servicesList[servicesList.length - index - 1];

                        return SearchServiceTile(
                          onPressed: () {
                            //TODO need to take spaces out of value
                            FirebaseAnalytics().logEvent(
                                name:
                                    'search_button_clicked_for_${service.databaseValue}');

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
