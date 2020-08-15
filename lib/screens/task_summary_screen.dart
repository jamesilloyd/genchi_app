import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
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
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:provider/provider.dart';

class TaskSummaryScreen extends StatefulWidget {
  @override
  _TaskSummaryScreenState createState() => _TaskSummaryScreenState();
}

class _TaskSummaryScreenState extends State<TaskSummaryScreen> {
  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  bool showSpinner = false;
  List userAccountIds;

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: 'home/task_summary_screen');
  }

  @override
  Widget build(BuildContext context) {
    print('Task Summary Screen Activated');
    final authProvider = Provider.of<AuthenticationService>(context);
    final taskProvider = Provider.of<TaskService>(context);
    User currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    userAccountIds = currentUser.providerProfiles;
    userAccountIds.add(currentUser.id);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: CircularProgress(),
      child: DefaultTabController(
          length: userIsProvider ? 2 : 1,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                title: Text(
                  'Jobs Manager',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Color(kGenchiGreen),
                elevation: 2.0,
                brightness: Brightness.light,
                bottom: TabBar(
                    indicatorColor: Color(kGenchiOrange),
                    labelColor: Colors.black,
                    labelStyle: TextStyle(
                      fontSize: 20,
                      fontFamily: 'FuturaPT',
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: 'Posted'),
                      if (userIsProvider) Tab(text: 'Applied For'),
                    ])),
            body: TabBarView(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.all(15),
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        RoundedButton(
                          onPressed: () async {
                            bool postTask = await showYesNoAlert(
                                context: context, title: 'Post Job?');
                            if (postTask)
                              Navigator.pushNamed(context, PostTaskScreen.id);
                          },
                          buttonColor: Color(kGenchiOrange),
                          fontColor: Color(kGenchiCream),
                          buttonTitle: '+ Post Job',
                          elevation: true,
                        ),
                      ],
                    ),
                    Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Your Posted Jobs',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 0,
                      thickness: 1,
                    ),
                    FutureBuilder(
                      future: firestoreAPI.getUserTasksPostedAndNotifications(
                          postIds: currentUser.posts),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            height: 60,
                            child: Center(
                              child: CircularProgress(),
                            ),
                          );
                        }

                        final List<Map<String, dynamic>>
                            userTasksAndNotifications = snapshot.data;

                        if (userTasksAndNotifications.isEmpty) {
                          return Container(
                            height: 30,
                            child: Center(
                              child: Text(
                                'You have not posted a job',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        }

                        List<Widget> taskWidgets = [];

                        for (Map taskAndNotification
                            in userTasksAndNotifications) {
                          Task task = taskAndNotification['task'];
                          bool userHasNotification =
                              taskAndNotification['hasNotification'];

                          Widget tCard = TaskCard(
                              image: currentUser.displayPictureURL == null
                                  ? null
                                  : CachedNetworkImageProvider(
                                      currentUser.displayPictureURL),
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
                                Navigator.pushNamed(context, TaskScreen.id)
                                    .then((value) {
                                  setState(() {});
                                });
                              });
                          taskWidgets.add(tCard);
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: taskWidgets,
                        );
                      },
                    ),
                  ],
                ),
                if (userIsProvider)
                  SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(15),
                      children: <Widget>[
                        Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              'Your Applied Jobs',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: 0,
                          thickness: 1,
                        ),
                        FutureBuilder(
                          future: firestoreAPI
                              .getUserTasksAppliedAndNotifications(
                                  accountIds: userAccountIds),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                height: 60,
                                child: Center(
                                  child: CircularProgress(),
                                ),
                              );
                            }

                            final List<Map<String, dynamic>>
                                tasksAndHirersAndNotification = snapshot.data;

                            if (tasksAndHirersAndNotification.isEmpty) {
                              return Container(
                                height: 30,
                                child: Center(
                                  child: Text(
                                    'You have not applied to any jobs',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              );
                            }
                            List<Widget> taskWidgets = [];

                            for (Map taskAndHirerAndNotification
                                in tasksAndHirersAndNotification) {
                              Task task = taskAndHirerAndNotification['task'];
                              User hirer = taskAndHirerAndNotification['hirer'];
                              bool providerHasNotification =
                                  taskAndHirerAndNotification[
                                      'hasNotification'];

                              Widget tCard = TaskCard(
                                  image: hirer.displayPictureURL == null
                                      ? null
                                      : CachedNetworkImageProvider(
                                          hirer.displayPictureURL),
                                  task: task,
                                  hasUnreadMessage: providerHasNotification,
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

                                    Navigator.pushNamed(context, TaskScreen.id)
                                        .then((value) {
                                      setState(() {});
                                    });
                                  });
                              taskWidgets.add(tCard);
                            }

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: taskWidgets,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )),
    );
  }
}
