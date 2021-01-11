import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:genchi_app/screens/post_task_and_hirer_screen.dart';
import 'package:genchi_app/screens/post_task_screen.dart';
import 'package:genchi_app/screens/task_screen_applicant.dart';
import 'package:genchi_app/screens/task_screen_hirer.dart';
import 'package:genchi_app/services/account_service.dart';
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
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;

  final ScrollController _listScrollController = ScrollController();
  PanelController _panelController = PanelController();
  Future searchTasksFuture;
  Future getUserTasksPostedAndNotificationsFuture;
  Future getUserTasksAppliedFuture;
  String filter = 'ALL';
  bool _isVisible = true;
  bool _isExpanded = false;
  String appliedPosted = 'Posted';

  // int postedNotifications = 0;
  // int appliedNotifications = 0;

  double buttonHeight;

  //TODO: "no jobs" not appearing under filter (remove "coming soon")

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  void openBottomSection() async {
    await Duration(milliseconds: 500);

    _panelController.animatePanelToPosition(0.08,
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
              _panelController.animatePanelToPosition(0.08,
                  duration: Duration(milliseconds: 150));
              _isVisible = true;
            });
          }
        }
      }
    });

    GenchiUser currentUser =
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
    final accountService =  Provider.of<AccountService>(context);
    GenchiUser currentUser = authProvider.currentUser;

    if (debugMode) print('Job screen activated');
    buttonHeight = 0.08 *
        (MediaQuery.of(context).size.height -
            kToolbarHeight -
            AppBar().preferredSize.height -
            25);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BasicAppNavigationBar(
        barTitle: 'Home',
      ),
      body: SlidingUpPanel(
        snapPoint: 0.08,
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
              height: 25 + buttonHeight,
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
                          child: Container(
                            width: MediaQuery.of(context).size.width / 8,
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
                          child: Container(
                            width: MediaQuery.of(context).size.width / 8,
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
                        ),
                      ]),
                  SizedBox(
                    height: buttonHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isExpanded) {
                                _panelController.animatePanelToPosition(1.0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn);
                                _isExpanded = true;
                              }
                              setState(() {
                                appliedPosted = 'Posted';
                              });
                            },
                            child: Container(
                              foregroundDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0, 1.5),
                                  end: Alignment(0, 0.5),
                                  colors: [
                                    appliedPosted == 'Applied'
                                        ? Colors.black12
                                        : Colors.transparent,
                                    Colors.transparent
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10)),
                                color: Color(kGenchiLightOrange),
                              ),
                              child: Center(
                                child: Text(
                                  'Posted',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isExpanded) {
                                _panelController.animatePanelToPosition(1.0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn);
                                _isExpanded = true;
                              }
                              setState(() {
                                appliedPosted = 'Applied';
                              });
                            },
                            child: Container(
                              foregroundDecoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0, 1.5),
                                  end: Alignment(0, 0.5),
                                  colors: [
                                    appliedPosted == 'Posted'
                                        ? Colors.black12
                                        : Colors.transparent,
                                    Colors.transparent
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10)),
                                color: Color(kGenchiLightGreen),
                              ),
                              child: Center(
                                child: Text(
                                  'Applied To',
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
              color: appliedPosted == 'Posted'
                  ? Color(kGenchiLightOrange)
                  : Color(kGenchiLightGreen),
              height: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  AppBar().preferredSize.height -
                  25 -
                  buttonHeight,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 15),
                children: [
                  SizedBox(height: 15),
                  Center(
                    child: Text(
                      appliedPosted == 'Posted'
                          ? "Opportunities you've posted"
                          : "Opportunities you've applied to",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: appliedPosted == 'Posted',
                    child: FutureBuilder(
                      future: getUserTasksPostedAndNotificationsFuture,
                      builder: (context, snapshot) {
                        final List<Map<String, dynamic>>
                            userTasksAndNotifications = snapshot.data;

                        List<List<Widget>> taskWidgets = [[], [], []];

                        if (snapshot.hasData) {
                          if (userTasksAndNotifications.isEmpty) {
                            return Container(
                              height: 30,
                              child: Center(
                                child: Text(
                                  'You have not posted an opportunity!',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          }

                          for (Map taskAndNotification
                              in userTasksAndNotifications) {
                            Task task = taskAndNotification['task'];
                            bool userHasNotification =
                                taskAndNotification['hasNotification'];

                            Widget tCard = TaskCard(
                                orangeBackground: true,
                                imageURL: currentUser.displayPictureURL,
                                task: task,
                                hasUnreadMessage: userHasNotification,
                                isDisplayTask: false,
                                onTap: () async {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  await taskProvider.updateCurrentTask(
                                      taskId: task.taskId);

                                  setState(() {
                                    showSpinner = false;
                                  });

                                  bool isUsersTask =
                                      taskProvider.currentTask.hirerId ==
                                          currentUser.id;

                                  Navigator.pushNamed(
                                          context,
                                          isUsersTask
                                              ? TaskScreenHirer.id
                                              : TaskScreenApplicant.id)
                                      .then((value) {
                                    ///Refresh the tasks to remove notifications.
                                    getUserTasksPostedAndNotificationsFuture =
                                        firestoreAPI
                                            .getUserTasksPostedAndNotifications(
                                                postIds: currentUser.posts);
                                    setState(() {});
                                  });
                                });

                            if (task.status == 'Vacant') {
                              taskWidgets[0].add(tCard);
                            } else if (task.status == 'InProgress') {
                              taskWidgets[1].add(tCard);
                            } else if (task.status == 'Completed') {
                              taskWidgets[2].add(tCard);
                            }
                          }
                        }

                        return PostedAppliedList(
                            taskWidgets: taskWidgets, isPosted: true);
                      },
                    ),
                  ),
                  Visibility(
                    visible: appliedPosted == 'Applied',
                    child: FutureBuilder(
                      future: getUserTasksAppliedFuture,
                      builder: (context, snapshot) {
                        final List<Map<String, dynamic>>
                            tasksAndHirersAndNotification = snapshot.data;

                        List<List<Widget>> taskWidgets = [[], [], []];

                        if (snapshot.hasData) {
                          if (tasksAndHirersAndNotification.isEmpty) {
                            return Container(
                              height: 30,
                              child: Center(
                                child: Text(
                                  'You have not applied to an opportunity!',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          }

                          for (Map taskAndHirerAndNotification
                              in tasksAndHirersAndNotification) {
                            Task task = taskAndHirerAndNotification['task'];
                            GenchiUser hirer =
                                taskAndHirerAndNotification['hirer'];
                            bool userHasNotification =
                                taskAndHirerAndNotification['hasNotification'];

                            Widget tCard = TaskCard(
                                imageURL: hirer.displayPictureURL,
                                task: task,
                                hasUnreadMessage: userHasNotification,
                                isDisplayTask: false,
                                onTap: () async {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  await taskProvider.updateCurrentTask(
                                      taskId: task.taskId);

                                  setState(() {
                                    showSpinner = false;
                                  });

                                  bool isUsersTask =
                                      taskProvider.currentTask.hirerId ==
                                          currentUser.id;

                                  Navigator.pushNamed(
                                          context,
                                          isUsersTask
                                              ? TaskScreenHirer.id
                                              : TaskScreenApplicant.id)
                                      .then((value) {
                                    getUserTasksAppliedFuture = firestoreAPI
                                        .getUserTasksAppliedAndNotifications(
                                            providerIds:
                                                currentUser.providerProfiles,
                                            mainId: currentUser.id);
                                    setState(() {});
                                  });
                                });
                            if (task.status == 'Vacant') {
                              taskWidgets[0].add(tCard);
                            } else if (task.status == 'InProgress') {
                              taskWidgets[1].add(tCard);
                            } else if (task.status == 'Completed') {
                              taskWidgets[2].add(tCard);
                            }
                          }
                        }

                        return PostedAppliedList(
                            taskWidgets: taskWidgets, isPosted: false);
                      },
                    ),
                  ),
                  SizedBox(height: 100),
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
                  SizedBox(height: 25),
                  PostJobSection(
                    text: 'Post New Opportunity',
                    onPressed: () async {
                      bool postTask = await showYesNoAlert(
                          context: context, title: 'Post Opportunity?');
                      if (postTask)
                        Navigator.pushNamed(context, PostTaskScreen.id)
                            .then((value) {
                          ///Update futures
                          searchTasksFuture =
                              firestoreAPI.fetchTasksAndHirers();
                          getUserTasksPostedAndNotificationsFuture =
                              firestoreAPI.getUserTasksPostedAndNotifications(
                                  postIds: currentUser.posts);
                          setState(() {});
                        });
                    },
                  ),
                  if (currentUser.admin)
                    PostJobSection(
                      text: 'Post New Opportunity and Hirer',
                      onPressed: () async {
                        bool postTask = await showYesNoAlert(
                            context: context,
                            title: 'Post Opportunity and Hirer?',
                            body:
                                'This will create a new user as soon as you click, so make sure to do it in one go');
                        if (postTask) {

                          ///Create an empty user
                          DocumentReference result = await firestoreAPI.addUser(GenchiUser());
                          await firestoreAPI.updateUser(user: GenchiUser(id: result.id), uid: result.id);

                          ///Update the account service to be on this user
                          await accountService.updateCurrentAccount(id: result.id);

                          Navigator.pushNamed(
                                  context, PostTaskAndHirerScreen.id)
                              .then((value) {
                            ///Update futures
                            searchTasksFuture =
                                firestoreAPI.fetchTasksAndHirers();
                            getUserTasksPostedAndNotificationsFuture =
                                firestoreAPI.getUserTasksPostedAndNotifications(
                                    postIds: currentUser.posts);
                            setState(() {});
                          });
                        }
                      },
                    ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'OPPORTUNITIES',
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
                              for (Service service in opportunityTypeList) {
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

                      // final List<Widget> widgets = [];

                      if (tasksAndHirers.isEmpty) {
                        return Container(
                          height: 40,
                          child: Center(
                            child: Text(
                              'No opportunities yet. Check again later',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: tasksAndHirers.length,
                          itemBuilder: (context, index) {
                            Map taskAndHirer = tasksAndHirers[index];
                            Task task = taskAndHirer['task'];
                            GenchiUser hirer = taskAndHirer['hirer'];

                            if ((task.service == filter) || (filter == 'ALL')) {
                              return TaskCard(
                                imageURL: hirer.displayPictureURL,
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

                                  ///Check whether it is the users task or not
                                  bool isUsersTask =
                                      taskProvider.currentTask.hirerId ==
                                          currentUser.id;

                                  if (isUsersTask) {
                                    Navigator.pushNamed(
                                        context, TaskScreenHirer.id);
                                  } else {
                                    ///If viewing someone else's task, add their id to the viewedIds if it hasn't been added yet
                                    if (!taskProvider.currentTask.viewedIds
                                        .contains(currentUser.id))
                                      await firestoreAPI.addViewedIdToTask(
                                          viewedId: currentUser.id,
                                          taskId: task.taskId);
                                    Navigator.pushNamed(
                                        context, TaskScreenApplicant.id);
                                  }
                                },
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
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

class PostedAppliedList extends StatelessWidget {
  List taskWidgets;
  bool isPosted;

  PostedAppliedList({@required this.taskWidgets, @required this.isPosted});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            isPosted ? 'RECEIVING APPLICATIONS' : 'APPLIED',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xff5415BA)),
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
        if (taskWidgets[0].isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              'Nothing to show',
              style: TextStyle(fontSize: 16),
            )),
          ),
        Column(
          children: taskWidgets[0],
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'IN PROGRESS',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xff41820E)),
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
        if (taskWidgets[1].isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              'Nothing to show',
              style: TextStyle(fontSize: 16),
            )),
          ),
        Column(
          children: taskWidgets[1],
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'COMPLETED',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xffDA2222)),
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
        if (taskWidgets[2].isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              'Nothing to show',
              style: TextStyle(fontSize: 16),
            )),
          ),
        Column(
          children: taskWidgets[2],
        ),
      ],
    );
  }
}

class PostJobSection extends StatelessWidget {
  Function onPressed;
  String text;

  PostJobSection({@required this.onPressed, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            onPressed: onPressed,
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
                    text,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
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
