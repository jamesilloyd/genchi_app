import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/platform_alerts.dart';
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
import 'package:sliding_up_panel/sliding_up_panel.dart';

class JobsScreen extends StatefulWidget {
  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;

  final ScrollController _listScrollController = ScrollController();
  PanelController _panelController = PanelController();
  Future searchTasksFuture;
  Future getUserTasksPostedAndNotificationsFuture;
  Future getUserTasksAppliedFuture;
  String filter = 'ALL';
  bool _isVisible = true;
  bool _isExpanded = false;
  double height = 0;
  String appliedPosted = 'Posted';

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();


  void openBottomSection() async {
    await Duration(milliseconds: 500);

    _panelController.animatePanelToPosition(0.07,
        duration: Duration(milliseconds: 150));
  }

  @override
  void initState() {
    super.initState();

    _listScrollController.addListener(() {
      if (_listScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible == true) {
          setState(() {
            _panelController.animatePanelToPosition(0,
                duration: Duration(milliseconds: 150));
            _isVisible = false;
          });
        }
      } else {
        if (_listScrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            setState(() {
              _panelController.animatePanelToPosition(0.07,
                  duration: Duration(milliseconds: 150));
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

    openBottomSection();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskService>(context);
    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;

    if (debugMode) print('Job screen activated');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BasicAppNavigationBar(
        barTitle: 'Jobs',
      ),
      body: SlidingUpPanel(
        snapPoint: 0.07,
        onPanelClosed: () {
          setState(() {
            _isExpanded = false;
          });
        },
        onPanelOpened: () {
          setState(() {
            _isExpanded = true;
          });
        },
        boxShadow: [BoxShadow(color: Colors.transparent)],
        color: Colors.transparent,
        minHeight: 25,
        maxHeight: MediaQuery.of(context).size.height -
            kToolbarHeight -
            AppBar().preferredSize.height,
        controller: _panelController,
        panel: Column(
          children: [
            Container(
              height: 25 +
                  0.07 *
                      (MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          AppBar().preferredSize.height -
                          25),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _panelController.animatePanelToPosition(
                                _isExpanded ? 0 : 1.0,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn);
                            _isExpanded = !_isExpanded;
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: getUserTasksPostedAndNotificationsFuture,
                            builder: (context, snapshot) {
                              final List<Map<String, dynamic>>
                                  userTasksAndNotifications = snapshot.data;

                              int notifications = 0;

                              ///Check how many notifications the user has
                              if (snapshot.hasData) {
                                for (Map taskAndNotification
                                    in userTasksAndNotifications) {
                                  bool userHasNotification =
                                      taskAndNotification['hasNotification'];
                                  if (userHasNotification) notifications++;
                                }
                              }

                              return Stack(
                                alignment: Alignment.centerRight,
                                overflow: Overflow.visible,
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 8,
                                    height: 25,
                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      color: Color(kGenchiLightOrange),
                                    ),
                                    child: Icon(
                                      _isExpanded
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_up,
                                      size: 30,
                                    ),
                                  ),
                                  if(notifications != 0) Positioned(
                                    right: -10,
                                    child: Container(
                                      alignment: Alignment(100,100),
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white,width: 2)
                                      ),
                                      child: Center(
                                        child: Text(
                                          notifications.toString(),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _panelController.animatePanelToPosition(
                                _isExpanded ? 0 : 1.0,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.fastOutSlowIn);
                            _isExpanded = !_isExpanded;
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: getUserTasksAppliedFuture,
                            builder: (context, snapshot) {

                              int notifications = 0;

                              final List<Map<String, dynamic>>
                              tasksAndHirersAndNotification = snapshot.data;

                              ///Check how many notifications the user has
                              if (snapshot.hasData) {
                                for (Map taskAndHirerAndNotification
                                in tasksAndHirersAndNotification) {
                                  bool userHasNotification =
                                  taskAndHirerAndNotification['hasNotification'];
                                  if (userHasNotification) notifications++;
                                }
                              }

                              return Stack(
                                alignment: Alignment.centerLeft,
                                overflow: Overflow.visible,
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width:
                                    MediaQuery.of(context).size.width / 8,
                                    height: 25,
                                    decoration: BoxDecoration(

                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      color: Color(kGenchiLightGreen),
                                    ),
                                    child: Icon(
                                      _isExpanded
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_up,
                                      size: 30,
                                    ),
                                  ),
                                  if(notifications != 0) Positioned(
                                    left: -10,
                                    child: Container(
                                      alignment: Alignment(100,100),
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white,width: 2)
                                      ),
                                      child: Center(
                                        child: Text(
                                          notifications.toString(),
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: 0.07 *
                        (MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            AppBar().preferredSize.height -
                            25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            /*TODO: here we want to add functionality that:
                               - will select the correct filter
                                -will expand the list if not already expanded
                                -will not close the list if already expanded*/
                            onTap: () {
                              setState(() {
                                appliedPosted = 'Posted';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10)),
                                color: Color(kGenchiLightOrange),
                              ),
                              child: Center(
                                child: Text(
                                  'Posted Jobs',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                appliedPosted = 'Applied';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10)),
                                color: Color(kGenchiLightGreen),
                              ),
                              child: Center(
                                child: Text(
                                  'Jobs Applied To',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  AppBar().preferredSize.height -
                  25 -
                  0.07 *
                      (MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          AppBar().preferredSize.height -
                          25),
              child: ListView(
                children: [
                  // FutureBuilder(),
                  SizedBox(
                    height: 25 +
                        0.07 *
                            (MediaQuery.of(context).size.height -
                                kToolbarHeight -
                                AppBar().preferredSize.height -
                                25),
                  )
                ],
              ),
            ),
          ],
        ),
        body: ModalProgressHUD(
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
                physics: AlwaysScrollableScrollPhysics(),
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
                            offset: Offset(0, 2),
                          )
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  FutureBuilder(
                    future: getUserTasksPostedAndNotificationsFuture,
                    builder: (context, snapshot) {
                      final List<Map<String, dynamic>>
                          userTasksAndNotifications = snapshot.data;

                      int notifications = 0;

                      ///Check how many notifications the user has
                      if (snapshot.hasData) {
                        for (Map taskAndNotification
                            in userTasksAndNotifications) {
                          bool userHasNotification =
                              taskAndNotification['hasNotification'];
                          if (userHasNotification) notifications++;
                        }
                      }
                      return GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (notifications != 0)
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Color(kGenchiOrange),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    notifications.toString(),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            SizedBox(width: 10),
                            Text(
                              'YOUR POSTED JOBS',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        onTap: !snapshot.hasData
                            ? () {}
                            : () async {
                                await showModalBottomSheet(
                                  context: context,
                                  shape: modalBottomSheetBorder,
                                  isScrollControlled: true,
                                  builder: (context) => StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setModalState) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      padding: EdgeInsets.all(15.0),
                                      decoration:
                                          modalBottomSheetContainerDecoration,
                                      child: ListView(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: 25),
                                              Container(
                                                height: 50,
                                                child: Center(
                                                  child: Text(
                                                    'Your Posted Jobs',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 25.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 25,
                                                  color: Colors.black,
                                                ),
                                              )
                                            ],
                                          ),
                                          Divider(
                                            height: 0,
                                            thickness: 1,
                                          ),
                                          FutureBuilder(
                                            future:
                                                getUserTasksPostedAndNotificationsFuture,
                                            builder: (context, snapshot) {
                                              final List<Map<String, dynamic>>
                                                  userTasksAndNotifications =
                                                  snapshot.data;
                                              List<Widget> taskWidgets = [];

                                              if (snapshot.hasData) {
                                                if (userTasksAndNotifications
                                                    .isEmpty) {
                                                  return Container(
                                                    height: 30,
                                                    child: Center(
                                                      child: Text(
                                                        'You have not posted a job!',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                for (Map taskAndNotification
                                                    in userTasksAndNotifications) {
                                                  Task task =
                                                      taskAndNotification[
                                                          'task'];
                                                  bool userHasNotification =
                                                      taskAndNotification[
                                                          'hasNotification'];

                                                  Widget tCard = TaskCard(
                                                      hirerType: currentUser
                                                          .accountType,
                                                      image: currentUser
                                                                  .displayPictureURL ==
                                                              null
                                                          ? null
                                                          : CachedNetworkImageProvider(
                                                              currentUser
                                                                  .displayPictureURL),
                                                      task: task,
                                                      hasUnreadMessage:
                                                          userHasNotification,
                                                      isDisplayTask: false,
                                                      onTap: () async {
                                                        setState(() {
                                                          showSpinner = true;
                                                        });

                                                        await taskProvider
                                                            .updateCurrentTask(
                                                                taskId: task
                                                                    .taskId);

                                                        setState(() {
                                                          showSpinner = false;
                                                        });
                                                        Navigator.pushNamed(
                                                                context,
                                                                TaskScreen.id)
                                                            .then((value) {
                                                          ///Refresh the tasks to remove notifications.
                                                          getUserTasksPostedAndNotificationsFuture =
                                                              firestoreAPI.getUserTasksPostedAndNotifications(
                                                                  postIds:
                                                                      currentUser
                                                                          .posts);
                                                          setModalState(() {});
                                                        });
                                                      });
                                                  taskWidgets.add(tCard);
                                                }
                                              }

                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: taskWidgets,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ).then((value) => setState(() {}));
                              },
                      );
                    },
                  ),
                  Divider(
                    height: 5,
                    thickness: 1,
                  ),
                  SizedBox(height: 10),
                  FutureBuilder(
                    future: getUserTasksAppliedFuture,
                    builder: (context, snapshot) {
                      int notifications = 0;

                      final List<Map<String, dynamic>>
                          tasksAndHirersAndNotification = snapshot.data;

                      ///Check how many notifications the user has
                      if (snapshot.hasData) {
                        for (Map taskAndHirerAndNotification
                            in tasksAndHirersAndNotification) {
                          bool userHasNotification =
                              taskAndHirerAndNotification['hasNotification'];
                          if (userHasNotification) notifications++;
                        }
                      }

                      return GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (notifications != 0)
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Color(kGenchiOrange),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    notifications.toString(),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            SizedBox(width: 10),
                            Text(
                              'YOUR APPLIED JOBS',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        onTap: !snapshot.hasData
                            ? () {}
                            : () async {
                                await showModalBottomSheet(
                                  context: context,
                                  shape: modalBottomSheetBorder,
                                  isScrollControlled: true,
                                  builder: (context) => StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setModalState) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      padding: EdgeInsets.all(15.0),
                                      decoration:
                                          modalBottomSheetContainerDecoration,
                                      child: ListView(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: 25),
                                              Container(
                                                height: 50,
                                                child: Center(
                                                  child: Text(
                                                    'Your Applied Jobs',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 25.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 25,
                                                  color: Colors.black,
                                                ),
                                              )
                                            ],
                                          ),
                                          Divider(
                                            height: 0,
                                            thickness: 1,
                                          ),
                                          FutureBuilder(
                                            future: getUserTasksAppliedFuture,
                                            builder: (context, snapshot) {
                                              final List<Map<String, dynamic>>
                                                  tasksAndHirersAndNotification =
                                                  snapshot.data;

                                              List<Widget> taskWidgets = [];

                                              if (snapshot.hasData) {
                                                for (Map taskAndHirerAndNotification
                                                    in tasksAndHirersAndNotification) {
                                                  Task task =
                                                      taskAndHirerAndNotification[
                                                          'task'];
                                                  User hirer =
                                                      taskAndHirerAndNotification[
                                                          'hirer'];
                                                  bool userHasNotification =
                                                      taskAndHirerAndNotification[
                                                          'hasNotification'];

                                                  if (userHasNotification)
                                                    notifications++;

                                                  Widget tCard = TaskCard(
                                                      hirerType:
                                                          hirer.accountType,
                                                      image: hirer.displayPictureURL ==
                                                              null
                                                          ? null
                                                          : CachedNetworkImageProvider(
                                                              hirer
                                                                  .displayPictureURL),
                                                      task: task,
                                                      hasUnreadMessage:
                                                          userHasNotification,
                                                      isDisplayTask: false,
                                                      onTap: () async {
                                                        setState(() {
                                                          showSpinner = true;
                                                        });

                                                        await taskProvider
                                                            .updateCurrentTask(
                                                                taskId: task
                                                                    .taskId);

                                                        setState(() {
                                                          showSpinner = false;
                                                        });

                                                        Navigator.pushNamed(
                                                                context,
                                                                TaskScreen.id)
                                                            .then((value) {
                                                          getUserTasksAppliedFuture =
                                                              firestoreAPI.getUserTasksAppliedAndNotifications(
                                                                  providerIds:
                                                                      currentUser
                                                                          .providerProfiles,
                                                                  mainId:
                                                                      currentUser
                                                                          .id);
                                                          setModalState(() {});
                                                        });
                                                      });
                                                  taskWidgets.add(tCard);
                                                }
                                              }

                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: taskWidgets,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ).then((value) => setState(() {}));
                              },
                      );
                    },
                  ),
                  Divider(
                    height: 5,
                    thickness: 1,
                  ),
                  SizedBox(height: 10),
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
                                      child: Text(
                                          service.databaseValue.toUpperCase()),
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
                  SizedBox(
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
