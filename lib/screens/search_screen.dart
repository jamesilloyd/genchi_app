import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/task_card.dart';

import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_screen.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'search_provider_screen.dart';
import 'package:provider/provider.dart';

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

  TextEditingController searchTextController = TextEditingController();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  Future searchTasksFuture;

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  bool showSpinner = false;
  String filter = 'ALL';

  Map<String, Future> serviceFutures = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

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
            //TODO need to take spaces out of value
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
    final taskProvider = Provider.of<TaskService>(context);
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
              child: LiquidPullToRefresh(
                key: _refreshIndicatorKey,
                color: Color(kGenchiOrange),
                backgroundColor: Colors.white,
                showChildOpacityTransition: false,
                borderWidth: 0.75,
                animSpeedFactor: 2,
                height: 40,
                onRefresh: () async {
                  searchTasksFuture = firestoreAPI.fetchTasksAndHirers();
                  setState(() {});
                },
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'PROVIDERS',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            //TODO add this in when we have more services on the app
//                            GestureDetector(
//                              onTap: () {},
//                              child: Text(
//                                'See all',
//                                textAlign: TextAlign.end,
//                                style: TextStyle(
//                                    fontWeight: FontWeight.w500,
//                                    fontSize: 16,
//                                    color: Color(kGenchiGreen)),
//                              ),
//                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 0,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: (MediaQuery.of(context).size.width - 40) /
                              (2.5 * 1.6) +
                          15,
                      child: Center(
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          scrollDirection: Axis.horizontal,
                          children: buildServiceTiles(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'JOBS',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                                child: Align(
                              alignment: Alignment.bottomCenter,
                              child: PopupMenuButton(
                                  elevation: 1,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          filter.toUpperCase(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(width: 5),
                                        ImageIcon(
                                          AssetImage('images/filter.png'),
                                          color: Colors.black,
                                          size: 30,
                                        ),

                                        SizedBox(
                                          width: 5,
                                        )
                                      ]),
                                  itemBuilder: (_) {
                                    List<PopupMenuItem<String>> items = [
                                      const PopupMenuItem<String>(
                                          child: const Text('ALL'),
                                          value: 'ALL'),
                                    ];
                                    for (Service service in servicesList) {
                                      items.add(
                                        new PopupMenuItem<String>(
                                            child: Text(service.databaseValue
                                                .toUpperCase()),
                                            value: service.databaseValue),
                                      );
                                    }
                                    return items;
                                  },
                                  onSelected: (value) {
                                    setState(() {
                                      filter = value;
                                    });
                                  }),
                            )),
                            //TODO: add this when we have more search options
//                            GestureDetector(
//                              onTap: () {
//                                Navigator.pushNamed(context, SearchTasksScreen.id);
//                              },
//                              child: Text(
//                                'See all',
//                                textAlign: TextAlign.end,
//                                style: TextStyle(
//                                    fontWeight: FontWeight.w500,
//                                    fontSize: 16,
//                                    color: Color(kGenchiGreen)),
//                              ),
//                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 0,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: FutureBuilder(
                        future: searchTasksFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              height: 60,
                              child: Center(
                                child: CircularProgress(),
                              ),
                            );
                          }
                          final List<Map<String, dynamic>> tasksAndHirers =
                              snapshot.data;

                          final List<Widget> widgets = [];

                          for (Map taskAndHirer in tasksAndHirers) {
                            Task task = taskAndHirer['task'];
                            User hirer = taskAndHirer['hirer'];

                            if ((task.service == filter) || (filter == 'ALL')) {
                              final widget = TaskCard(
                                image: hirer.displayPictureURL == null
                                    ? null
                                    : CachedNetworkImageProvider(
                                        hirer.displayPictureURL),
                                task: task,
                                onTap: () async {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  await taskProvider.updateCurrentTask(
                                      taskId: task.taskId);

                                  setState(() {
                                    showSpinner = false;
                                  });
                                  Navigator.pushNamed(context, TaskScreen.id);
                                },
                              );

                              widgets.add(widget);
                            }
                          }

                          if (widgets.isEmpty) {
                            return Container(
                              height: 40,
                              child: Center(
                                child: Text(
                                  'No jobs yet. Check again later',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: widgets,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
