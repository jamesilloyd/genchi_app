import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/snackbars.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/application_chat_screen.dart';
import 'package:genchi_app/screens/edit_provider_account_screen.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/screens/user_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:genchi_app/models/task.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskScreen extends StatefulWidget {
  static const id = 'task_screen';

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool showSpinner = false;
  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  List userPidsAndId = [];

  TextStyle titleTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );

  Widget buildHirersTask({@required Task task, bool isAdmin = false}) {
    ///User is looking at their own task
    return FutureBuilder(
      future: firestoreAPI.getTaskApplicants(taskId: task.taskId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgress();
        }

        final List<Map<String, dynamic>> applicationAndProviders =
            snapshot.data;

        if (applicationAndProviders.isEmpty) {
          return Center(
            child: Text(
              'No Applicants Yet',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        List<Widget> widgets = [
          Center(
            child: Text(
              'Applicants',
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
            indent: 15,
            endIndent: 15,
          ),
        ];

        for (Map applicationAndProvider in applicationAndProviders) {
          TaskApplication taskApplication =
              applicationAndProvider['application'];
          GenchiUser applicant = applicationAndProvider['applicant'];

          MessageListItem chatWidget = MessageListItem(
            imageURL: applicant.displayPictureURL,
              name: applicant.name,
              service: applicant.category,
              type: 'JOB',
              lastMessage: taskApplication.lastMessage,
              time: taskApplication.time,
              hasUnreadMessage: taskApplication.hirerHasUnreadMessage,
              onTap: () async {
                setState(() {
                  showSpinner = true;
                });

                GenchiUser hirer = await firestoreAPI.getUserById(task.hirerId);

                ///Checking that the hirer exists before segue
                if (hirer != null) {
                  ///If it isn't an admin entering the conversation, remove the notification
                  if (!isAdmin) {
                    taskApplication.hirerHasUnreadMessage = false;

                    ///Update the task application
                    await firestoreAPI.updateTaskApplication(
                        taskApplication: taskApplication);
                  }

                  setState(() {
                    showSpinner = false;
                  });

                  ///Segue to application chat screen with user as hirer
                  Navigator.pushNamed(context, ApplicationChatScreen.id,
                          arguments: ApplicationChatScreenArguments(
                              adminView: isAdmin,
                              taskApplication: taskApplication,
                              userIsApplicant: false,
                              applicant: applicant,
                              hirer: hirer))
                      .then((value) {
                    setState(() {});
                  });
                }
              },

              //TODO add ability to delete applicant
              hideChat: () {});

          widgets.add(chatWidget);
        }

        return Column(
          children: widgets,
        );
      },
    );
  }

  Widget buildApplicantsTask(
      {@required Function applyFunction,
      @required List userpidsAndId,
      @required Task task}) {
    ///User is looking at someone else's task, provide them with the option to apply
    return FutureBuilder(
      future: firestoreAPI.getTaskApplicants(taskId: task.taskId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgress();
        }

        //TODO this is not the most steamline way to do this
        bool applied = false;
        GenchiUser appliedAccount;
        TaskApplication usersApplication;
        final List<Map<String, dynamic>> applicantsAndProviders = snapshot.data;

        for (var applicantAndProvider in applicantsAndProviders) {
          GenchiUser applicant = applicantAndProvider['applicant'];
          TaskApplication application = applicantAndProvider['application'];

          if (userpidsAndId.contains(applicant.id)) {
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
              indent: 15,
              endIndent: 15,
            ),
          ];

          ///Show user's application
          MessageListItem chatWidget = MessageListItem(
            imageURL: appliedAccount.displayPictureURL,
              name: appliedAccount.name,
              service: appliedAccount.category,
              lastMessage: usersApplication.lastMessage,
              time: usersApplication.time,
              type: appliedAccount.accountType,
              hasUnreadMessage: usersApplication.applicantHasUnreadMessage,
              onTap: () async {
                setState(() {
                  showSpinner = true;
                });
                GenchiUser hirer = await firestoreAPI.getUserById(task.hirerId);

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
                    setState(() {});
                  });
                }
              },
              deleteMessage: 'Withdraw',
              hideChat: () async {
                bool withdraw = await showYesNoAlert(
                    context: context, title: 'Withdraw your application?');

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

                  setState(() {
                    showSpinner = false;
                  });
                }
              });

          widgets.add(chatWidget);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          );
        } else {
          ///user has not applied
          return Center(
            child: RoundedButton(
              fontColor: Colors.black,
              buttonColor: Color(kGenchiLightOrange),
              buttonTitle: 'APPLY',
              onPressed: applyFunction,
              elevation: true,
            ),
          );
        }
      },
    );
  }

  Widget buildAdminSection(
      {@required BuildContext context, @required Task currentTask}) {
    return Column(
      children: <Widget>[
        Divider(
          thickness: 1,
        ),
        Center(
            child: Text(
          'Admin Controls',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
        )),
        Center(
          child: Text('id: ${currentTask.taskId}'),
        ),
        RoundedButton(
          buttonTitle: 'Delete task',
          buttonColor: Color(kGenchiBlue),
          elevation: false,
          onPressed: () async {
            bool deleteTask = await showYesNoAlert(
                context: context,
                title: 'Are you sure you want to delete this job?');

            if (deleteTask) {
              setState(() {
                showSpinner = true;
              });

              TaskService taskService =
                  Provider.of<TaskService>(context, listen: false);

              AuthenticationService authService =
                  Provider.of<AuthenticationService>(context, listen: false);

              await firestoreAPI.deleteTask(task: taskService.currentTask);
              await authService.updateCurrentUserData();
              setState(() {
                showSpinner = false;
              });

              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.id, (Route<dynamic> route) => false,
                  arguments: HomeScreenArguments(startingIndex: 0));
            }
          },
        ),
        buildHirersTask(task: currentTask, isAdmin: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (debugMode) print('Task Screen: activated');
    final authProvider = Provider.of<AuthenticationService>(context);
    final taskProvider = Provider.of<TaskService>(context);
    final accountService = Provider.of<AccountService>(context);
    GenchiUser currentUser = authProvider.currentUser;
    Task currentTask = taskProvider.currentTask;
    bool isUsersTask = currentTask.hirerId == currentUser.id;

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
        actions: <Widget>[
          if (isUsersTask)
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
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgress(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  FutureBuilder(
                    ///We probably don't need to check that the user exists here as the
                    ///task would have been deleted if the hirer doesn't exist.
                    ///Worst case scenario the infite scoller appears
                    future: firestoreAPI.getUserById(currentTask.hirerId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text('');
                      }
                      GenchiUser hirer = snapshot.data;

                      return GestureDetector(
                        onTap: () async {
                          await accountService.updateCurrentAccount(
                              id: currentTask.hirerId);
                          Navigator.pushNamed(context, UserScreen.id);
                        },
                        child: Row(
                          children: [
                            hirer.displayPictureURL == null

                                ///Show default image
                                ? CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Color(0xffC4C4C4),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Icon(
                                        Icons.person,
                                        color: Color(0xff585858),
                                        size: 35,
                                      ),
                                    ),
                                  )

                                ///Show provider image
                                : Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(kGenchiCream),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image(
                                      image: CachedNetworkImageProvider(
                                          hirer.displayPictureURL),
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    ),
                                  ),
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
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    hirer.bio,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    "Posted ${getTaskPostedTime(time: currentTask.time)}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(kGenchiOrange)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Text('Category', style: titleTextStyle),
                  Divider(
                    thickness: 1,
                    height: 8,
                  ),
                  Text(
                    currentTask.service.toUpperCase(),
                    style: TextStyle(fontSize: 22, color: Color(kGenchiOrange)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text("Details",
                        textAlign: TextAlign.left, style: titleTextStyle),
                  ),
                  Divider(
                    thickness: 1,
                    height: 8,
                  ),
                  SelectableLinkify(
                    text: currentTask.details ?? "",
                    onOpen: _onOpenLink,
                    options: LinkifyOptions(humanize: false),
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Text("Job Timings",
                        textAlign: TextAlign.left, style: titleTextStyle),
                  ),
                  Divider(
                    thickness: 1,
                    height: 8,
                  ),
                  SelectableLinkify(
                    text: currentTask.date ?? "",
                    onOpen: _onOpenLink,
                    options: LinkifyOptions(humanize: false),
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Text("Incentive",
                        textAlign: TextAlign.left, style: titleTextStyle),
                  ),
                  Divider(
                    thickness: 1,
                    height: 8,
                  ),
                  SelectableText(
                    currentTask.price ?? "",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
            isUsersTask
                ? buildHirersTask(task: currentTask)
                : buildApplicantsTask(
                    task: currentTask,
                    userpidsAndId: userPidsAndId,
                    applyFunction: () async {
                      String selectedId = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: modalBottomSheetBorder,
                        builder: (context) => Container(
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
                              )),
                              SizedBox(
                                height: 40,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'General Account',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
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
                                      context: context,
                                      title: 'Apply with this account?');
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
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
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
                                        final List<GenchiUser>
                                            serviceProviders = snapshot.data;

                                        List<UserCard> userCards = [];

                                        for (GenchiUser serviceProvider
                                            in serviceProviders) {
                                          UserCard userCard = UserCard(
                                            user: serviceProvider,
                                            onTap: () async {
                                              bool apply = await showYesNoAlert(
                                                  context: context,
                                                  title:
                                                      'Apply with this account?');
                                              if (apply) {
                                                Navigator.pop(context,
                                                    serviceProvider.id);
                                              }
                                            },
                                          );

                                          userCards.add(userCard);
                                        }

                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: userCards,
                                        );
                                      },
                                    ),
                                    if (currentUser.providerProfiles.isEmpty)
                                      RoundedButton(
                                        buttonColor: Color(kGenchiGreen),
                                        buttonTitle:
                                            'Create a service account first?',
                                        onPressed: () async {
                                          bool createAccount = await showYesNoAlert(
                                              context: context,
                                              title:
                                                  'Create a service account before applying to this job?');
                                          if (createAccount) {
                                            ///Log event in firebase
                                            await analytics.logEvent(
                                                name:
                                                    'provider_account_created');

                                            AuthenticationService authService =
                                                Provider.of<
                                                        AuthenticationService>(
                                                    context,
                                                    listen: false);
                                            AccountService accountService =
                                                Provider.of<AccountService>(
                                                    context,
                                                    listen: false);

                                            DocumentReference result =
                                                await firestoreAPI.addServiceProvider(
                                                    serviceUser: GenchiUser(
                                                        mainAccountId:
                                                            authService
                                                                .currentUser.id,
                                                        accountType:
                                                            'Service Provider',
                                                        displayPictureURL:
                                                            authService
                                                                .currentUser
                                                                .displayPictureURL,
                                                        displayPictureFileName:
                                                            authService
                                                                .currentUser
                                                                .displayPictureFileName),
                                                    uid: authService
                                                        .currentUser.id);

                                            await authService
                                                .updateCurrentUserData();

                                            await accountService
                                                .updateCurrentAccount(
                                                    id: result.id);

                                            //TODO is there a way to reload? rather then closing the modal and having to reopen?

                                            Navigator.pushNamed(
                                                    context, UserScreen.id)
                                                .then((value) {
                                              Navigator.pop(context);
                                            });
                                            Navigator.pushNamed(context,
                                                EditProviderAccountScreen.id);
                                          }
                                        },
                                      )
                                  ],
                                )
                            ],
                          ),
                        ),
                      );

                      if (debugMode)
                        print('Task Screen: applied with id $selectedId');

                      if (selectedId != null) {
                        setState(() {
                          showSpinner = true;
                        });

                        await analytics.logEvent(name: 'task_application_sent');

                        DocumentReference chatRef =
                            await firestoreAPI.applyToTask(
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
                            ///Refresh screen
                            setState(() {});
                          });
                        }
                      }
                    },
                  ),
            if (currentUser.admin)
              buildAdminSection(context: context, currentTask: currentTask),
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

//TODO add in hovering apply button
// Align(
//   alignment: Alignment.bottomCenter,
//   child: Padding(
//     padding: const EdgeInsets.all(30.0),
//     child: Container(
//       height: 70,
//       child: RoundedButton(
//         elevation: false,
//         buttonTitle: 'APPLY',
//         buttonColor: Color(kGenchiLightOrange),
//         fontColor: Colors.black,
//         onPressed: (){},
//       ),
//     ),
//   ),
// )
