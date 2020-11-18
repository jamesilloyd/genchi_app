import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/snackbars.dart';
import 'package:genchi_app/components/task_text_body.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/application_chat_screen.dart';
import 'package:genchi_app/screens/edit_provider_account_screen.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';
import 'package:genchi_app/screens/user_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:genchi_app/models/task.dart';

import 'package:genchi_app/services/time_formatting.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO: WHEN FINISHED ADD IN ADMIN CONTROLS
//TODO: WHEN FINISHED ADD IN MODAL PROGRESS FOR ASYNC
//TODO: do front end then add in the back end
class TaskScreenApplicant extends StatefulWidget {
  static const id = 'task_screen_applicant';

  @override
  _TaskScreenApplicantState createState() => _TaskScreenApplicantState();
}

class _TaskScreenApplicantState extends State<TaskScreenApplicant> {
  TextStyle titleTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );

  bool showSpinner = false;
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  List userPidsAndId = [];

  Future hirerFuture;
  Future applicantsFuture;

  @override
  void initState() {
    super.initState();
    Task task = Provider.of<TaskService>(context, listen: false).currentTask;
    hirerFuture = firestoreAPI.getUserById(task.hirerId);
    applicantsFuture = firestoreAPI.getTaskApplicants(task: task);
  }

  @override
  Widget build(BuildContext context) {
    if (debugMode) print('Task Screen: activated');
    final authProvider = Provider.of<AuthenticationService>(context);
    final taskProvider = Provider.of<TaskService>(context);
    final accountService = Provider.of<AccountService>(context);
    GenchiUser currentUser = authProvider.currentUser;
    Task currentTask = taskProvider.currentTask;

    userPidsAndId.clear();
    userPidsAndId.addAll(currentUser.providerProfiles);
    userPidsAndId.add(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          'Job',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(kGenchiGreen),
        elevation: 2.0,
        brightness: Brightness.light,
      ),
      bottomNavigationBar: showSpinner ? SizedBox.shrink(): ActionButton(
        userpidsAndId: userPidsAndId,
        applicantsFuture: applicantsFuture,
        applyFunction: () async {
          String selectedId = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: modalBottomSheetBorder,
            builder: (context) => ApplyToJob(currentUser: currentUser),
          );

          if (debugMode) print('Task Screen: applied with id $selectedId');

          if (selectedId != null) {
            setState(() {
              showSpinner = true;
            });

            await analytics.logEvent(name: 'task_application_sent');

            DocumentReference chatRef = await firestoreAPI.applyToTask(
                taskId: currentTask.taskId,
                applicantId: selectedId,
                hirerId: currentTask.hirerId);

            TaskApplication taskApplication =
                await firestoreAPI.getTaskApplicationById(
              taskId: currentTask.taskId,
              applicationId: chatRef.id,
            );

            GenchiUser applicantProfile =
                await firestoreAPI.getUserById(selectedId);

            GenchiUser hirer =
                await firestoreAPI.getUserById(currentTask.hirerId);

            setState(() {
              showSpinner = false;
            });

            ///Check all necessary documents exist before entering chat
            if (hirer != null &&
                applicantProfile != null &&
                taskApplication != null) {
              Navigator.pushNamed(context, ApplicationChatScreen.id,
                  arguments: ApplicationChatScreenArguments(
                    isInitialApplication: true,
                    taskApplication: taskApplication,
                    hirer: hirer,
                    applicant: applicantProfile,
                    userIsApplicant: true,
                  )).then((value) {
                authProvider.updateCurrentUserData();

                applicantsFuture =
                    firestoreAPI.getTaskApplicants(task: currentTask);

                ///Refresh screen
                setState(() {});
              });
            }
          }
        },
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgress(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: SelectableText(
                    currentTask.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () async {
                          bool likesFeature = await showYesNoAlert(
                              context: context,
                              title: 'Share this job with a friend?');

                          if (likesFeature != null) {
                            analytics.logEvent(
                                name: 'share_job_button_pressed',
                                parameters: {'response': likesFeature});

                            if (likesFeature) {
                              Scaffold.of(context)
                                  .showSnackBar(kDevelopmentFeature);
                            }
                          }
                        },
                        icon: Icon(
                          Platform.isIOS ? Icons.ios_share : Icons.share,
                          size: 25,
                        ),
                      );
                    },
                    // child:
                  ),
                )
              ],
            ),
            Divider(
              thickness: 1,
              height: 10,
            ),
            SizedBox(
              height: 5,
            ),

            ///APPLICANT VIEW
            FutureBuilder(
              ///We probably don't need to check that the user exists here as the
              ///task would have been deleted if the hirer doesn't exist.
              ///Worst case scenario the infite scoller appears
              future: hirerFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('');
                }
                GenchiUser hirer = snapshot.data;

                return GestureDetector(
                  onTap: () async {
                    await Provider.of<AccountService>(context, listen: false)
                        .updateCurrentAccount(id: currentTask.hirerId);
                    Navigator.pushNamed(context, UserScreen.id);
                  },
                  child: Row(
                    children: [
                      ListDisplayPicture(
                          imageUrl: hirer.displayPictureURL, height: 90),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hirer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              hirer.bio,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            Text(
                              "Posted ${getTaskPostedTime(time: currentTask.time)}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, color: Color(kGenchiOrange)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),

            ///KEEP
            TaskDetailsSection(
              task: currentTask,
              linkOpen: _onOpenLink,
            ),

            ///Show the applicant's application (this returns a sizedBox if not applied)
            FutureBuilder(
              future: applicantsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgress();
                }

                bool applied = false;
                GenchiUser appliedAccount;
                TaskApplication usersApplication;
                final List<Map<String, dynamic>> applicantsAndProviders =
                    snapshot.data;

                for (var applicantAndProvider in applicantsAndProviders) {
                  GenchiUser applicant = applicantAndProvider['applicant'];
                  TaskApplication application =
                      applicantAndProvider['application'];

                  if (userPidsAndId.contains(applicant.id)) {
                    ///currentUser has applied
                    applied = true;
                    appliedAccount = applicant;
                    usersApplication = application;
                  }
                }

                if (applied) {
                  ///user has already applied
                  List<Widget> widgets = [
                    Center(
                      child: Text(
                        'Your Application',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      height: 0,
                      thickness: 1,
                    ),
                  ];

                  ///Show user's application
                  ApplicantListItem chatWidget = ApplicantListItem(
                    imageURL: appliedAccount.displayPictureURL,
                    name: appliedAccount.name,
                    lastMessage: usersApplication.lastMessage,
                    time: usersApplication.time,
                    hasUnreadMessage:
                        usersApplication.applicantHasUnreadMessage,
                    onTap: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      GenchiUser hirer =
                          await firestoreAPI.getUserById(currentTask.hirerId);

                      ///Check that the hirer exists before opening chat
                      if (hirer != null) {
                        usersApplication.applicantHasUnreadMessage = false;
                        await firestoreAPI.updateTaskApplication(
                            taskApplication: usersApplication);

                        setState(() {
                          showSpinner = false;
                        });

                        ///Segue to application chat screen with user as the applicant
                        Navigator.pushNamed(context, ApplicationChatScreen.id,
                            arguments: ApplicationChatScreenArguments(
                              hirer: hirer,
                              userIsApplicant: true,
                              taskApplication: usersApplication,
                              applicant: appliedAccount,
                            )).then((value) {
                          setState(() {
                            applicantsFuture = firestoreAPI.getTaskApplicants(task: currentTask);

                          });
                        });
                      }
                    },
                  );

                  widgets.add(chatWidget);

                  Widget withdraw = Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: RoundedButton(
                        buttonTitle: 'Withdraw',
                        buttonColor: Color(kGenchiLightGreen),
                        onPressed: () async {
                          bool withdraw = await showYesNoAlert(
                              context: context,
                              title: 'Are you sure you want to withdraw your application?');

                          if (withdraw) {
                            setState(() {
                              showSpinner = true;
                            });

                            await analytics.logEvent(
                                name: 'applicant_removed_application');

                            await firestoreAPI.removeTaskApplicant(
                                applicantId: appliedAccount.id,
                                applicationId: usersApplication.applicationId,
                                taskId: usersApplication.taskid);

                            await Provider.of<AuthenticationService>(context,
                                    listen: false)
                                .updateCurrentUserData();

                            setState(() {
                              showSpinner = false;
                              applicantsFuture = firestoreAPI.getTaskApplicants(task: currentTask);
                            });
                          }
                        },
                        fontColor: Colors.black,
                        elevation: false,
                      ),
                    ),
                  );

                  widgets.add(withdraw);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widgets,
                  );
                } else {
                  ///user has not applied
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    if (link.runtimeType == EmailElement) {
      //TODO handle email elements
    } else {
      String url = link.url;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $link';
      }
    }
  }
}

class ActionButton extends StatelessWidget {
  final Future applicantsFuture;
  final Function applyFunction;
  final List userpidsAndId;

  ActionButton({
    @required this.applicantsFuture,
    @required this.applyFunction,
    @required this.userpidsAndId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: applicantsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }

          bool applied = false;

          ///CHeck if the user has already applied to the task
          final List<Map<String, dynamic>> applicantsAndProviders =
              snapshot.data;

          for (var applicantAndProvider in applicantsAndProviders) {
            GenchiUser applicant = applicantAndProvider['applicant'];

            if (userpidsAndId.contains(applicant.id)) {
              ///currentUser has applied
              applied = true;
            }
          }

          if (applied) {
            ///User has already applied so remove bottom bar
            return SizedBox.shrink();
          } else {
            ///User has not applied so show them the apply button
            return Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: MediaQuery.of(context).size.height * 0.012),
                child: RoundedButton(
                  elevation: false,
                  buttonTitle: 'APPLY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  buttonColor: Color(kGenchiLightOrange),
                  fontColor: Colors.black,
                  onPressed: applyFunction,
                ),
              ),
            );
          }
        });
  }
}

class ApplyToJob extends StatelessWidget {
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  GenchiUser currentUser;

  ApplyToJob({@required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.all(15.0),
      decoration: modalBottomSheetContainerDecoration,
      child: ListView(
        children: <Widget>[
          Center(
            child: Text(
              'Apply with which account?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'General Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
          ),
          UserCard(
            user: currentUser,
            onTap: () async {
              bool apply = await showYesNoAlert(
                  context: context, title: 'Apply with this account?');
              if (apply) {
                Navigator.pop(context, currentUser.id);
              }
            },
          ),
          if (currentUser.accountType == 'Individual')
            Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Service Account(s)',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
                FutureBuilder(
                  ///This function returns a list of providerUsers
                  future: firestoreAPI.getServiceProviders(
                      ids: currentUser.providerProfiles),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgress();
                    }
                    final List<GenchiUser> serviceProviders = snapshot.data;

                    List<UserCard> userCards = [];

                    for (GenchiUser serviceProvider in serviceProviders) {
                      UserCard userCard = UserCard(
                        user: serviceProvider,
                        onTap: () async {
                          bool apply = await showYesNoAlert(
                              context: context,
                              title: 'Apply with this account?');
                          if (apply) {
                            Navigator.pop(context, serviceProvider.id);
                          }
                        },
                      );

                      userCards.add(userCard);
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: userCards,
                    );
                  },
                ),
                if (currentUser.providerProfiles.isEmpty)
                  RoundedButton(
                    buttonColor: Color(kGenchiGreen),
                    buttonTitle: 'Create a service account first?',
                    onPressed: () async {
                      bool createAccount = await showYesNoAlert(
                          context: context,
                          title:
                              'Create a service account before applying to this job?');
                      if (createAccount) {
                        ///Log event in firebase
                        await analytics.logEvent(
                            name: 'provider_account_created');

                        AuthenticationService authService =
                            Provider.of<AuthenticationService>(context,
                                listen: false);
                        AccountService accountService =
                            Provider.of<AccountService>(context, listen: false);

                        DocumentReference result =
                            await firestoreAPI.addServiceProvider(
                                serviceUser: GenchiUser(
                                    mainAccountId: authService.currentUser.id,
                                    accountType: 'Service Provider',
                                    displayPictureURL: authService
                                        .currentUser.displayPictureURL,
                                    displayPictureFileName: authService
                                        .currentUser.displayPictureFileName),
                                uid: authService.currentUser.id);

                        await authService.updateCurrentUserData();

                        await accountService.updateCurrentAccount(
                            id: result.id);

                        //TODO is there a way to reload? rather then closing the modal and having to reopen?

                        Navigator.pushNamed(context, UserScreen.id)
                            .then((value) {
                          Navigator.pop(context);
                        });
                        Navigator.pushNamed(
                            context, EditProviderAccountScreen.id);
                      }
                    },
                  )
              ],
            )
        ],
      ),
    );
  }
}
