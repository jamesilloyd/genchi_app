import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/application_chat_screen.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';
import 'package:genchi_app/screens/hirer_screen.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/hirer_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  static const id = 'task_screen';

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool showSpinner = false;
  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  Widget buildVariableSection(
      {@required bool isUsersTask,
      @required bool userIsProvider,
      @required String hirerid,
      @required Function applyFunction,
      @required List userpids,
      @required Task task}) {
    if (isUsersTask) {
      ///User is looking at their own task
      return FutureBuilder(
        future: firestoreAPI.getTaskApplicants(taskId: task.taskId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress();
          }

          final List<Map<String, dynamic>> applicantsAndProviders =
              snapshot.data;

          if (applicantsAndProviders.isEmpty) {
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
            Divider(
              height: 5,
              thickness: 1,
            ),
          ];

          for (Map applicantAndProvider in applicantsAndProviders) {
            TaskApplicant taskApplicant = applicantAndProvider['applicant'];
            ProviderUser provider = applicantAndProvider['provider'];

            MessageListItem chatWidget = MessageListItem(
                image: provider.displayPictureURL == null
                    ? AssetImage("images/Logo_Clear.png")
                    : CachedNetworkImageProvider(provider.displayPictureURL),
                name: provider.name,
                service: provider.type,
                type: 'JOB',
                lastMessage: taskApplicant.lastMessage,
                time: taskApplicant.time,
                hasUnreadMessage: taskApplicant.hirerHasUnreadMessage,
                onTap: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  User hirer = await firestoreAPI.getUserById(hirerid);

                  ///Checking that the hirer exists before segue
                  if (hirer != null) {
                    taskApplicant.hirerHasUnreadMessage = false;

                    ///Update the task application
                    await firestoreAPI.updateTaskApplicant(
                        taskApplicant: taskApplicant);

                    setState(() {
                      showSpinner = false;
                    });

                    ///Segue to application chat screen with user as hirer
                    Navigator.pushNamed(context, ApplicationChatScreen.id,
                            arguments: ApplicationChatScreenArguments(
                              taskApplicant: taskApplicant,
                                userIsProvider: false,
                                provider: provider,
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
    } else if (!userIsProvider) {
      ///User cannot apply as they do not have a provider account
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                  child: Text(
                'Create a provider account to apply',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),),
            ],
          );
    } else {
      ///User is a provider so it's now a case of seeing if they have applied already
      return FutureBuilder(
        future: firestoreAPI.getTaskApplicants(taskId: task.taskId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress();
          }

          //TODO this is not the most steamline way to do this
          bool applied = false;
          ProviderUser appliedProvider;
          TaskApplicant providersApplication;
          final List<Map<String, dynamic>> applicantsAndProviders =
              snapshot.data;

          for (var applicantAndProvider in applicantsAndProviders) {
            ProviderUser provider = applicantAndProvider['provider'];
            TaskApplicant applicant = applicantAndProvider['applicant'];

            if (userpids.contains(provider.pid)) {
              ///currentuser has applied
              applied = true;
              appliedProvider = provider;
              providersApplication = applicant;
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
              )
            ];
            ///Show user's application
            MessageListItem chatWidget = MessageListItem(
                image: appliedProvider.displayPictureURL == null
                    ? AssetImage("images/Logo_Clear.png")
                    : CachedNetworkImageProvider(
                        appliedProvider.displayPictureURL),
                name: appliedProvider.name,
                service: appliedProvider.type,
                lastMessage: providersApplication.lastMessage,
                time: providersApplication.time,
                type: 'JOB',
                deleteMessage: 'Withdraw',
                hasUnreadMessage: providersApplication.providerHasUnreadMessage,
                onTap: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  User hirer = await firestoreAPI.getUserById(hirerid);

                  ///Check that the hirer exists before opening chat
                  if (hirer != null) {
                    providersApplication.providerHasUnreadMessage = false;
                    await firestoreAPI.updateTaskApplicant(
                        taskApplicant: providersApplication);

                    setState(() {
                      showSpinner = false;
                    });


                    ///Segue to application chat screen with user as the provider (applicant)
                    Navigator.pushNamed(context, ApplicationChatScreen.id, arguments:
                    ApplicationChatScreenArguments(
                      hirer: hirer,
                      userIsProvider: true,
                      taskApplicant: providersApplication,
                      provider: appliedProvider,
                    )).then((value) {
                        setState(() {});
                      });

                  }
                },
                hideChat: () async {
                  bool withdraw = await showYesNoAlert(
                      context: context, title: 'Withdraw your application?');

                  if (withdraw) {
                    setState(() {
                      showSpinner = true;
                    });

                    await firestoreAPI.removeTaskApplicant(
                        providerId: appliedProvider.pid,
                        applicationId: providersApplication.applicationId,
                        taskId: providersApplication.taskid);

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
                fontColor: Color(kGenchiCream),
                buttonColor: Color(kGenchiGreen),
                buttonTitle: 'Apply',
                onPressed: applyFunction,
                elevation: true,
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (debugMode) print('Task Screen: activated');
    final authProvider = Provider.of<AuthenticationService>(context);
    final taskProvider = Provider.of<TaskService>(context);
    final hirerProvider = Provider.of<HirerService>(context);
    User currentUser = authProvider.currentUser;
    Task currentTask = taskProvider.currentTask;
    bool isUsersTask = currentTask.hirerId == currentUser.id;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
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
                Platform.isIOS ? CupertinoIcons.settings : Icons.settings,
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
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    currentTask.title,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  currentTask.service,
//                textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(kGenchiOrange)
                  ),
                ),
              ],
            ),
            Divider(thickness: 1),
            Container(
              child: Text(
                "Details",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              currentTask.details ?? "",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                "Job Timings",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              currentTask.date ?? "",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                "Incentive",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              currentTask.price ?? "",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                "Date Posted",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              getTaskPostedTime(time: currentTask.time),
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 1,
            ),
            Text(
              'Hirer',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 10,
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
                User hirer = snapshot.data;
                return HirerCard(hirer: hirer, onTap: () async {
                  await hirerProvider.updateCurrentHirer(id:currentTask.hirerId );
                  Navigator.pushNamed(context, HirerScreen.id);
                });
              },
            ),
            Divider(
              thickness: 1,
            ),
            buildVariableSection(
              task: currentTask,
              isUsersTask: isUsersTask,
              userIsProvider: userIsProvider,
              userpids: currentUser.providerProfiles,
              hirerid: currentTask.hirerId,
              applyFunction: () async {
                if (userIsProvider) {
                  String selectedProviderId = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color(kGenchiCream),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: ListView(
                        children: <Widget>[
                          Center(
                              child: Text(
                            'Apply with which provider account?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                          Divider(
                            height: 1,
                            thickness: 1,
                          ),
                          FutureBuilder(
                            //This function returns a list of providerUsers
                            future: firestoreAPI.getProviders(
                                pids: currentUser.providerProfiles),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgress();
                              }
                              final List<ProviderUser> providers =
                                  snapshot.data;

                              List<ProviderCard> providerCards = [];

                              for (ProviderUser provider in providers) {
                                ProviderCard pCard = ProviderCard(
                                  provider: provider,
                                  onTap: () {
                                    Navigator.pop(context, provider.pid);
                                  },
                                );

                                providerCards.add(pCard);
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: providerCards,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                  if (debugMode)
                    print('Task Screen: applied with pid $selectedProviderId');

                  if (selectedProviderId != null) {
                    setState(() {
                      showSpinner = true;
                    });


                    DocumentReference chatRef = await firestoreAPI.applyToTask(
                        taskId: currentTask.taskId,
                        providerId: selectedProviderId,
                        userId: currentTask.hirerId);

                    TaskApplicant taskApplicant = await firestoreAPI.getTaskApplicantById(taskId: currentTask.taskId,applicantId:chatRef.documentID,);


                    ProviderUser providerProfile = await firestoreAPI.getProviderById(selectedProviderId);
                    User hirer = await firestoreAPI.getUserById(currentTask.hirerId);

                    setState(() {
                      showSpinner = false;
                    });

                    ///Check all necessary documents exist before entering chat
                    if (hirer != null &&
                        providerProfile != null && taskApplicant != null) {

                      Navigator.pushNamed(context, ApplicationChatScreen.id,arguments: ApplicationChatScreenArguments(
                        taskApplicant: taskApplicant,
                        hirer: hirer,
                        provider: providerProfile,
                        userIsProvider: true,
                      )).then((value) {
                        ///Refresh screen
                        setState(() {});
                      });
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
