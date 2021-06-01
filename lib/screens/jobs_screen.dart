import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/snackbars.dart';
import 'package:genchi_app/components/task_card.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/preferences.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/customer_needs_screen.dart';
import 'package:genchi_app/screens/post_task_and_hirer_screen.dart';
import 'package:genchi_app/screens/post_task_screen.dart';
import 'package:genchi_app/screens/pre_payment_explain_screen.dart';
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

import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

class Sort {
  bool value = true;
}

class JobsScreen extends StatefulWidget {
  static const id = 'jobs_screen';

  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with AutomaticKeepAliveClientMixin {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;

  final ScrollController _listScrollController = ScrollController();
  TextEditingController requestTextController = TextEditingController();
  PanelController _panelController = PanelController();
  Future searchTasksFuture;
  Future getUserTasksPostedAndNotificationsFuture;
  Future getUserTasksAppliedFuture;
  Future checkForAppUpdate;
  bool _isVisible = true;
  bool _isExpanded = false;
  String appliedPosted = 'Posted';

  //TODO: this is ugly
  Sort sortDeadline = Sort();

  // int postedNotifications = 0;
  // int appliedNotifications = 0;

  List<Tag> allTags = List.generate(
      originalTags.length, (index) => Tag.fromTag(originalTags[index]));

  double buttonHeight;

  @override
  void dispose() {
    super.dispose();
    requestTextController.dispose();
  }

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  void openBottomSection() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _panelController.animatePanelToPosition(0.08,
        duration: Duration(milliseconds: 150));
  }

  void checkForPreferenceUpdate() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    Navigator.pushNamed(context, CustomerNeedsScreen.id,
        arguments: PreferencesScreenArguments(isFromHome: true));
  }

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: 'home/jobs_screen');

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
    Provider.of<AccountService>(context, listen: false)
        .updateCurrentAccount(id: currentUser.id);

    searchTasksFuture = firestoreAPI.fetchTasksAndHirers();

    getUserTasksPostedAndNotificationsFuture = firestoreAPI
        .getUserTasksPostedAndNotifications(postIds: currentUser.posts);

    getUserTasksAppliedFuture =
        firestoreAPI.getUserTasksAppliedAndNotifications(
            providerIds: currentUser.providerProfiles, mainId: currentUser.id);

    checkForAppUpdate = firestoreAPI.checkForAppUpdate(
        currentVersion: currentUser.versionNumber);

    openBottomSection();
    if (!currentUser.hasSetPreferences) checkForPreferenceUpdate();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final taskProvider = Provider.of<TaskService>(context);
    final authProvider = Provider.of<AuthenticationService>(context);
    final accountService = Provider.of<AccountService>(context);
    GenchiUser currentUser = authProvider.currentUser;

    if (debugMode) print('Job screen activated');
    buttonHeight = 0.08 *
        (MediaQuery.of(context).size.height -
            kToolbarHeight -
            AppBar().preferredSize.height -
            25);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
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
                                  imageURL: currentUser.displayPicture200URL ?? currentUser.displayPictureURL,
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
                                  taskAndHirerAndNotification[
                                      'hasNotification'];

                              Widget tCard = TaskCard(
                                  imageURL: hirer.displayPicture200URL ?? hirer.displayPictureURL,
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
                    Center(
                      child: PostJobSection(
                        text: 'Post New Opportunity',
                        onPressed: () async {
                          if (currentUser.accountType != 'Company') {
                            bool postTask = await showYesNoAlert(
                                context: context, title: 'Post Opportunity?');
                            if (postTask)
                              Navigator.pushNamed(context, PostTaskScreen.id)
                                  .then((value) {
                                ///Update futures
                                searchTasksFuture =
                                    firestoreAPI.fetchTasksAndHirers();
                                getUserTasksPostedAndNotificationsFuture =
                                    firestoreAPI
                                        .getUserTasksPostedAndNotifications(
                                            postIds: currentUser.posts);
                                setState(() {});
                              });
                          } else {
                            Navigator.pushNamed(context, PrePaymentScreen.id);
                          }
                        },
                      ),
                    ),
                    FutureBuilder(
                        future: checkForAppUpdate,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
                          } else {
                            final bool doesNotNeedUpdate = snapshot.data;

                            if (doesNotNeedUpdate) {
                              return SizedBox.shrink();
                            } else {
                              return AppUpdateButton();
                            }
                          }
                        }),
                    if (currentUser.admin)
                      Center(
                        child: PostJobSection(
                          text: 'Post New Opportunity and Hirer',
                          onPressed: () async {
                            bool postTask = await showYesNoAlert(
                                context: context,
                                title: 'Post Opportunity and Hirer?',
                                body:
                                    'This will create a new user as soon as you click, so make sure to do it in one go');
                            if (postTask) {
                              ///Create an empty user
                              DocumentReference result =
                                  await firestoreAPI.addUser(GenchiUser());
                              await firestoreAPI.updateUser(
                                  user: GenchiUser(id: result.id),
                                  uid: result.id);

                              ///Update the account service to be on this user
                              await accountService.updateCurrentAccount(
                                  id: result.id);

                              Navigator.pushNamed(
                                      context, PostTaskAndHirerScreen.id)
                                  .then((value) {
                                ///Update futures
                                searchTasksFuture =
                                    firestoreAPI.fetchTasksAndHirers();
                                getUserTasksPostedAndNotificationsFuture =
                                    firestoreAPI
                                        .getUserTasksPostedAndNotifications(
                                            postIds: currentUser.posts);
                                setState(() {});
                              });
                            }
                          },
                        ),
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
                        GestureDetector(
                          onTap: () async {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0))),
                              builder: (context) => SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      child: HomePageSelectionScreen(
                                        allTags: allTags,
                                        sortDeadline: sortDeadline,
                                      )),
                                ),
                              ),
                            );
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              Text(
                                'FILTERS',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(width: 5),
                              ImageIcon(
                                AssetImage('images/filter.png'),
                                color: Colors.black,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 0,
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

                        ///This variable is for checking  if their filter returns a result
                        bool foundResults = false;
                        List searchResults = [];

                        ///Get all true values in the allTags list
                        List filteredTags = [];
                        for (Tag filter in allTags) {
                          if (filter.selected)
                            filteredTags.add(filter.databaseValue);
                        }

                        ///Go through the snapshot and check add any to a list to be presented
                        for (Map taskAndHirer in tasksAndHirers) {
                          bool addToSearchResults = true;
                          Task task = taskAndHirer['task'];

                          ///Just quickly check that the user is able to see this content
                          if (task.universities
                                  .contains(currentUser.university) ||
                              currentUser.accountType == 'Company') {
                            ///Evaluate these values against the task's tag
                            ///If they are all contained show
                            for (String filter in filteredTags) {
                              if (!task.tags.contains(filter)) {
                                addToSearchResults = false;
                              }
                            }

                            if (addToSearchResults) {
                              foundResults = true;
                              searchResults.add(taskAndHirer);
                            }
                          }
                        }

                        if (foundResults) {
                          ///Quickly resort the list if the user has selected to sort by posted date
                          if (!sortDeadline.value) {
                            searchResults.sort((a, b) {
                              Task taskA = a['task'];
                              Task taskB = b['task'];
                              return taskB.time.compareTo(taskA.time);
                            });
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              Map taskAndHirer = searchResults[index];
                              Task task = taskAndHirer['task'];
                              GenchiUser hirer = taskAndHirer['hirer'];

                              return BigTaskCard(
                                imageURL: hirer.displayPicture200URL ?? hirer.displayPictureURL,
                                task: task,
                                uni: hirer.university,
                                newTask: task.time
                                        .toDate()
                                        .difference(DateTime.now())
                                        .inHours >
                                    -36,
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
                            },
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    "No search results...\n\nLet us know what you're looking for and we will do our best to find that for you.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextField(
                                  maxLines: null,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left,
                                  cursorColor: Color(kGenchiOrange),
                                  controller: requestTextController,
                                  decoration: kEditAccountTextFieldDecoration
                                      .copyWith(hintText: 'Enter request'),
                                ),
                                RoundedButton(
                                  buttonTitle: 'Submit Request',
                                  buttonColor: Color(kGenchiLightGreen),
                                  fontColor: Colors.black,
                                  elevation: true,
                                  onPressed: () async {
                                    ///Send results
                                    await firestoreAPI.sendOpportunityFeedback(
                                        filters: filteredTags,
                                        user: currentUser,
                                        request: requestTextController.text);

                                    requestTextController.clear();

                                    ///send snackbar
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(kSubmitRequestSnackbar);
                                  },
                                )
                              ],
                            ),
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
      ),
    );
  }
}

class PostedAppliedList extends StatelessWidget {
  final List taskWidgets;
  final bool isPosted;

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
  final Function onPressed;
  final String text;

  PostJobSection({@required this.onPressed, @required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
        padding: const EdgeInsets.all(10),
        height: 42.0,
        minWidth: 200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        onPressed: onPressed,
        color: Color(kGenchiLightOrange),
        onHighlightChanged: (pressed) {
          if (pressed) {
            HapticFeedback.lightImpact();
          }
        },
        splashColor: Colors.black12,
        highlightColor: Colors.transparent,
        elevation: 2,
        highlightElevation: 5,
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
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppUpdateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MaterialButton(
        color: Color(kGenchiBlue),
        padding: const EdgeInsets.all(10),
        height: 42.0,
        minWidth: 200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        splashColor: Colors.black12,
        highlightColor: Colors.transparent,
        elevation: 2,
        highlightElevation: 5,
        onPressed: () async {
          if (Platform.isIOS) {
            if (await canLaunch(GenchiAppStoreURL)) {
              await launch(GenchiAppStoreURL);
            } else {
              print("Could not open URL");
            }
          } else {
            if (await canLaunch(GenchiPlayStoreURL)) {
              await launch(GenchiPlayStoreURL);
            } else {
              print("Could not open URL");
            }
          }
        },
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Update Available',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18.0,
                    color: Colors.white),
              ),
              SizedBox(width: 10),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  color: Color(kGenchiOrange),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
