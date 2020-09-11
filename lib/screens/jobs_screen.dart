import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/task_card.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/post_task_screen.dart';
import 'package:genchi_app/screens/task_screen.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class JobsScreen extends StatefulWidget {
  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  final ScrollController _listScrollController = ScrollController();

  bool showSpinner = false;
  Future searchTasksFuture;
  Future getUserTasksPostedAndNotificationsFuture;
  Future getUserTasksAppliedFuture;
  String filter = 'ALL';
  bool _isVisible = true;

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  _scrollListener() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget dummyCells() {
    List<Widget> widgets = [];

    for (int number = 100; number >= 1; number--) {
      widgets.add(Container(
        height: 60,
        child: Center(
          child: Text(
            "This is box number: $number",
          ),
        ),
      ));
    }


    return Column(
      children: widgets,
    );
  }

  @override
  void initState() {
    super.initState();

    _listScrollController.addListener(() {
      if (_listScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible == true) {
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (_listScrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });

    User currentUser =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    analytics.setCurrentScreen(screenName: 'home/jobs_screen');
    searchTasksFuture = firestoreAPI.fetchTasksAndHirers();
    getUserTasksPostedAndNotificationsFuture = firestoreAPI
        .getUserTasksPostedAndNotifications(postIds: currentUser.posts);

    getUserTasksAppliedFuture =
        firestoreAPI.getUserTasksAppliedAndNotifications(
            providerIds: currentUser.providerProfiles, mainId: currentUser.id);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskService>(context);
    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;

    if (debugMode) print('Job screen activated');

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Align(
      //     alignment: Alignment.bottomRight,
      //     child: AnimatedContainer(
      //       duration: Duration(milliseconds: 150),
      //       height: _isVisible ? 70 : 25,
      //       width: _isVisible ? 70 : 25,
      //       child: FloatingActionButton(
      //         elevation: 2,
      //         highlightElevation: 0,
      //         splashColor: Color(kGenchiGreen),
      //         backgroundColor: Color(kGenchiLightGreen),
      //         onPressed: () async {
      //           bool postTask = await showYesNoAlert(
      //               context: context, title: 'Post Job?');
      //           if (postTask) Navigator.pushNamed(context, PostTaskScreen.id);
      //         },
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             if (_isVisible)
      //               Icon(
      //                 Icons.add,
      //                 color: Colors.black,
      //               ),
      //             if (_isVisible)
      //               Text(
      //                 'Post Job',
      //                 style: TextStyle(
      //                     color: Colors.black,
      //                     fontSize: 14,
      //                     fontWeight: FontWeight.w400),
      //               )
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      appBar: BasicAppNavigationBar(
        barTitle: 'Jobs',
      ),
      body: Stack(
        children: [
          ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: CircularProgress(),
            child: SafeArea(
              child: LiquidPullToRefresh(
                key: _refreshIndicatorKey,
                color: Color(kGenchiOrange),
                backgroundColor: Colors.white,
                showChildOpacityTransition: false,
                borderWidth: 0.75,
                animSpeedFactor: 2,
                height: 40,
                onRefresh: () async {
                  ///Update futures
                  searchTasksFuture = firestoreAPI.fetchTasksAndHirers();
                  getUserTasksPostedAndNotificationsFuture =
                      firestoreAPI.getUserTasksPostedAndNotifications(
                          postIds: currentUser.posts);

                  getUserTasksAppliedFuture =
                      firestoreAPI.getUserTasksAppliedAndNotifications(
                          providerIds: currentUser.providerProfiles,
                          mainId: currentUser.id);

                  setState(() {});
                },
                child: ListView(
                  controller: _listScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        height: 42.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.0),
                          color: Color(kGenchiLightOrange),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: FlatButton(
                            onPressed: () async {
                              bool postTask = await showYesNoAlert(
                                  context: context, title: 'Post Job?');
                              if (postTask)
                                Navigator.pushNamed(context, PostTaskScreen.id);
                            },
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Post New Job',
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'JOBS FEED',
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
                                      child: const Text('ALL'), value: 'ALL'),
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
                      ],
                    ),
                    Divider(
                      height: 5,
                      thickness: 1,
                    ),
                    FutureBuilder(
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
                              hirerType: hirer.accountType,
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
                    dummyCells(),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        color: Color(kGenchiLightOrange),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        size: 30,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      width: 60,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        color: Color(kGenchiLightGreen),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 150),
                height: _isVisible ? 50 : 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(10)),
                          color: Color(kGenchiLightOrange),
                        ),
                        height: 50,
                        child: Center(
                          child: Text(
                            'Posted Jobs',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(10)),
                          color: Color(kGenchiLightGreen),
                        ),
                        height: 50,
                        child: Center(
                          child: Text(
                            'Jobs Applied To',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
