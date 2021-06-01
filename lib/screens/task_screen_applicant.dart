import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
import 'package:genchi_app/screens/edit_task_screen.dart';
import 'package:genchi_app/screens/user_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/dynamic_link_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:genchi_app/models/task.dart';

import 'package:genchi_app/services/time_formatting.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  static final DynamicLinkService dynamicLinkService = DynamicLinkService();
  List userPidsAndId = [];

  Future hirerFuture;
  Future applicantsFuture;
  Future applicantWasSuccessfulFuture;

  @override
  void initState() {
    super.initState();
    Task task = Provider.of<TaskService>(context, listen: false).currentTask;
    GenchiUser user =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    hirerFuture = firestoreAPI.getUserById(task.hirerId);
    applicantsFuture = firestoreAPI.getTaskApplicants(task: task);
    applicantWasSuccessfulFuture =
        firestoreAPI.applicantWasSuccessful(task: task, applicantId: user.id);
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
          'Opportunity',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(kGenchiGreen),
        elevation: 2.0,
        brightness: Brightness.light,
        actions: <Widget>[
          if (currentUser.admin)
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () async {
                Navigator.pushNamed(context, EditTaskScreen.id);
              },
            )
        ],
      ),
      bottomNavigationBar: showSpinner
          ? SizedBox.shrink()
          : ActionButton(
              userpidsAndId: userPidsAndId,
              applicantsFuture: applicantsFuture,
              applyFunction: currentTask.linkApplicationType
                  ? () async {
                      bool apply = await showYesNoAlert(
                          context: context, title: 'Apply to this job?');

                      if (apply) {
                        ///Quickly check if the user has already applied
                        if (!currentUser.admin ||
                            currentTask.linkApplicationIds
                                .contains(currentUser.id)) {
                          await analytics.logEvent(
                              name: 'application_sent_link');
                          ///STORE THE USER / TASK relationship somewhere
                          await firestoreAPI.addLinkApplicantId(
                              taskId: currentTask.taskId,
                              applicantId: currentUser.id);
                        }

                        ///Send them to the location
                        if (await canLaunch(currentTask.applicationLink)) {
                          await launch(currentTask.applicationLink);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(kApplicationLinkNotWorking);
                          print("Could not open URL");
                        }
                      }
                    }
                  : () async {
                      //TODO: trying out without service profiles
                      // String selectedId = await showModalBottomSheet(
                      //   context: context,
                      //   isScrollControlled: true,
                      //   shape: modalBottomSheetBorder,
                      //   builder: (context) =>
                      //       ApplyToJob(currentUser: currentUser),
                      // );

                      // if (debugMode)
                      //   print('Task Screen: applied with id $selectedId');
                      //
                      // if (selectedId != null) {

                      bool apply = await showYesNoAlert(
                          context: context, title: 'Apply to this job?');
                      if (apply) {
                        setState(() {
                          showSpinner = true;
                        });

                        if (!currentUser.admin)
                          await analytics.logEvent(name: 'application_sent');

                        DocumentReference chatRef =
                            await firestoreAPI.applyToTask(
                                taskId: currentTask.taskId,
                                applicantId: currentUser.id,
                                hirerId: currentTask.hirerId);

                        TaskApplication taskApplication =
                            await firestoreAPI.getTaskApplicationById(
                          taskId: currentTask.taskId,
                          applicationId: chatRef.id,
                        );

                        //TODO: trying out without service profiles
                        // GenchiUser applicantProfile =
                        //     await firestoreAPI.getUserById(selectedId);

                        GenchiUser hirer =
                            await firestoreAPI.getUserById(currentTask.hirerId);

                        setState(() {
                          showSpinner = false;
                        });

                        ///Check all necessary documents exist before entering chat
                        /////TODO: trying out without service profiles
                        if (hirer != null &&
                            // applicantProfile != null &&
                            taskApplication != null) {
                          Navigator.pushNamed(context, ApplicationChatScreen.id,
                              arguments: ApplicationChatScreenArguments(
                                isInitialApplication: true,
                                taskApplication: taskApplication,
                                hirer: hirer,
                                //TODO: trying out without service profiles
                                // applicant: applicantProfile,
                                applicant: currentUser,
                                userIsApplicant: true,
                              )).then((value) {
                            authProvider.updateCurrentUserData();

                            applicantsFuture = firestoreAPI.getTaskApplicants(
                                task: currentTask);

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
                  flex: 5,
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
                      return Column(
                        children: [
                          IconButton(
                            onPressed: () async {

                              ///Generate a new dynamic link
                                String newLink = await dynamicLinkService.createDynamicLink(title: currentTask.title,taskId: currentTask.taskId);

                                ///Copy it to clipboard
                                Clipboard.setData(ClipboardData(text:newLink));

                                ///Let them know :)
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(kDeepLinkCreated);

                                await analytics.logEvent(
                                    name: 'share_job_button_pressed');


                            },
                            icon: Icon(
                              Platform.isIOS ? Icons.ios_share : Icons.share,
                              size: 25,
                              color: Color(kGenchiOrange),
                            ),
                          ),
                          Text('SHARE',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(kGenchiOrange)
                            ),),
                        ],
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
                          imageUrl: hirer.displayPicture500URL ?? hirer.displayPictureURL,  height: 90),
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
            if (currentUser.admin)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      currentTask.linkApplicationType
                          ? currentTask.viewedIds.length.toString() +
                              ' views - ' +
                              currentTask.linkApplicationIds.length.toString() +
                              ' applicants'
                          : currentTask.viewedIds.length.toString() + ' views',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey)),
                ],
              ),
            SizedBox(height: 10),
            Text('Opportunity Status',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                )),
            Divider(
              thickness: 1,
              height: 8,
            ),

            ///If the applicant is successful just show them the usual task status
            ///If the aren't successful just show them "not receiving applications"
            FutureBuilder(
                future: applicantWasSuccessfulFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  final bool success = snapshot.data;

                  if (currentTask.status == 'Vacant') {
                    return Text(
                      'ACCEPTING APPLICATIONS',
                      style: TextStyle(fontSize: 20, color: Color(kPurple)),
                    );
                  } else {
                    return Text(
                      success
                          ? (currentTask.status == 'InProgress'
                              ? 'IN PROGRESS'
                              : 'COMPLETED')
                          : "NOT RECEIVING APPLICATIONS",
                      style: TextStyle(
                        fontSize: 20,
                        color: success
                            ? (currentTask.status == 'InProgress'
                                ? Color(kGreen)
                                : Color(kRed))
                            : Color(kRed),
                      ),
                    );
                  }
                }),
            SizedBox(
              height: 10,
            ),

            ///Show the generic job details
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
                List<Widget> widgets = [];
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
                  widgets = [
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
                    imageURL: appliedAccount.displayPicture200URL ?? appliedAccount.displayPictureURL,
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
                            applicantsFuture = firestoreAPI.getTaskApplicants(
                                task: currentTask);
                          });
                        });
                      }
                    },
                  );

                  widgets.add(chatWidget);

                  ///Withdraw only available when task is still receiving applications
                  if (currentTask.status == 'Vacant') {
                    Widget withdraw = Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: RoundedButton(
                          buttonTitle: 'Withdraw',
                          buttonColor: Color(kGenchiLightGreen),
                          onPressed: () async {
                            bool withdraw = await showYesNoAlert(
                                context: context,
                                title:
                                    'Are you sure you want to withdraw your application?');

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
                                applicantsFuture = firestoreAPI
                                    .getTaskApplicants(task: currentTask);
                              });
                            }
                          },
                          fontColor: Colors.black,
                          elevation: false,
                        ),
                      ),
                    );

                    widgets.add(withdraw);
                  }
                }

                if (currentUser.admin) {
                  widgets.add(Column(
                    children: [
                      Center(
                        child: Text(
                          'Admin Controls',
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
                      Center(
                        child: Text("Task id: ${currentTask.taskId}"),
                      ),
                    ],
                  ));

                  for (var applicantAndProvider in applicantsAndProviders) {
                    GenchiUser applicant = applicantAndProvider['applicant'];
                    TaskApplication application =
                        applicantAndProvider['application'];

                    ApplicantListItem chatWidget = ApplicantListItem(
                      imageURL: applicant.displayPicture200URL ?? applicant.displayPictureURL,
                      name: applicant.name,
                      lastMessage: application.lastMessage,
                      time: application.time,
                      hasUnreadMessage: application.applicantHasUnreadMessage,
                      onTap: () async {
                        setState(() {
                          showSpinner = true;
                        });

                        GenchiUser hirer =
                            await firestoreAPI.getUserById(currentTask.hirerId);

                        ///Check that the hirer exists before opening chat
                        if (hirer != null) {
                          setState(() {
                            showSpinner = false;
                          });

                          ///Segue to application chat screen with user as the applicant
                          Navigator.pushNamed(context, ApplicationChatScreen.id,
                              arguments: ApplicationChatScreenArguments(
                                hirer: hirer,
                                userIsApplicant: true,
                                adminView: true,
                                taskApplication: application,
                                applicant: applicant,
                              ));
                        }
                      },
                    );

                    widgets.add(chatWidget);
                  }

                  widgets.add(Center(
                    child: RoundedButton(
                      fontColor: Colors.white,
                      buttonColor: Color(kGenchiBlue),
                      buttonTitle: 'Delete Opportunity',
                      onPressed: () async {
                        bool delete = await showYesNoAlert(
                            context: context,
                            title: 'Delete this opportunity?');

                        if (delete != null && delete) {
                          ///Log in firebase analytics
                          await analytics.logEvent(name: 'job_deleted');

                          await firestoreAPI.deleteTask(task: currentTask);

                          Navigator.pop(context);
                        }
                      },
                    ),
                  ));

                  widgets.add(Center(
                    child: RoundedButton(
                      fontColor: Colors.white,
                      buttonColor: Color(kGenchiGreen),
                      buttonTitle: 'Mark as completed',
                      onPressed: () async {
                        bool delete = await showYesNoAlert(
                            context: context,
                            title: 'Mark this opportunity as completed?');

                        if (delete != null && delete) {
                          ///Log in firebase analytics
                          await firestoreAPI.markTaskAsCompleted(task: currentTask);

                          Navigator.pop(context);
                        }
                      },
                    ),
                  ));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    if (link.runtimeType == EmailElement) {
      launch('mailto:${link.text}?subject=Genchi%20Opportunity');
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
