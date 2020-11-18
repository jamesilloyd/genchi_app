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

//TODO: do front end then add in the back end
class TaskScreenHirer extends StatefulWidget {
  static const id = 'task_screen_hirer';

  @override
  _TaskScreenHirerState createState() => _TaskScreenHirerState();
}

class _TaskScreenHirerState extends State<TaskScreenHirer> {
  bool showSpinner = false;
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  List userPidsAndId = [];

  Future applicantsFuture;

  @override
  void initState() {
    super.initState();
    Task task = Provider.of<TaskService>(context, listen: false).currentTask;
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
        actions: <Widget>[
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
          : Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: MediaQuery.of(context).size.height * 0.012),
                  child: RoundedButton(
                    elevation: false,
                    buttonTitle: 'Change Job Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    buttonColor: Color(kGenchiLightGreen),
                    fontColor: Colors.black,
                    onPressed: () async {
                      String status = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: modalBottomSheetBorder,
                        builder: (context) => ChangeJobStatus(
                          applicantsFuture: applicantsFuture,
                        ),
                      );

                      print("Status is: $status");
                      //TODO: need any more code here?
                    },
                  )),
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

            ///HIRER VIEW
            FutureBuilder(
              future: applicantsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgress();
                }

                bool hirerHasUnreadNotification = false;

                final List<Map<String, dynamic>> applicationAndApplicants =
                    snapshot.data;

                if (applicationAndApplicants.isEmpty) {
                  return Container(
                    color: Color(kGenchiCream),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 5),
                        tileColor: Color(kGenchiCream),
                        leading: ListDisplayPicture(
                          imageUrl: currentUser.displayPictureURL,
                          height: 56,
                        ),
                        title: Text(
                          'No Applicants Yet',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          //TODO: route through to hirer's profile
                        },
                      ),
                    ),
                  );
                }

                ///First create messageListItems for each chat
                List<Widget> applicationChatWidgets = [];

                for (Map<String, dynamic> applicationAndApplicant
                    in applicationAndApplicants) {
                  TaskApplication taskApplication =
                      applicationAndApplicant['application'];
                  GenchiUser applicant = applicationAndApplicant['applicant'];

                  if (taskApplication.hirerHasUnreadMessage)
                    hirerHasUnreadNotification = true;

                  MessageListItem chatWidget = MessageListItem(
                    imageURL: applicant.displayPictureURL,
                    name: applicant.name,
                    lastMessage: taskApplication.lastMessage,
                    time: taskApplication.time,
                    hasUnreadMessage: taskApplication.hirerHasUnreadMessage,
                    onTap: () async {
                      taskApplication.hirerHasUnreadMessage = false;

                      ///update the task application
                      await firestoreAPI.updateTaskApplication(
                          taskApplication: taskApplication);

                      Navigator.pushNamed(context, ApplicationChatScreen.id,
                              arguments: ApplicationChatScreenArguments(
                                  taskApplication: taskApplication,
                                  userIsApplicant: false,
                                  hirer: currentUser,
                                  applicant: applicant))
                          .then((value) {
                        setState(() {
                          ///Recall future to update chats
                          applicantsFuture =
                              firestoreAPI.getTaskApplicants(task: currentTask);
                        });
                      });
                    },
                    //TODO: remove this ability
                    hideChat: () {},
                  );

                  applicationChatWidgets.add(chatWidget);
                }

                return HirerTaskApplicants(
                  title: currentTask.title,
                  time: currentTask.time,
                  subtitleText:
                      '${applicationChatWidgets.length} applicant${applicationChatWidgets.length == 1 ? '' : 's'}',
                  hasUnreadMessage: hirerHasUnreadNotification,
                  messages: applicationChatWidgets,
                  hirer: currentUser,
                );
              },
            ),
            Text('Job Status',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                )),
            Divider(
              thickness: 1,
              height: 8,
            ),
            Text(
              currentTask.status == 'Vacant'
                  ? 'ACCEPTING APPLICATIONS'
                  : (currentTask.status == 'InProgress'
                      ? 'IN PROGRESS'
                      : 'COMPLETED'),
              style: TextStyle(fontSize: 22, color: Color(0xff5415BA)),
            ),
            SizedBox(
              height: 10,
            ),

            //TODO: turn this into a button like the share button.
            if (currentTask.status != 'Vacant')
              Container(
                width: MediaQuery.of(context).size.width * 0.6 - 15,
                height: (MediaQuery.of(context).size.width * 0.6 - 15) * 0.2,
                decoration: BoxDecoration(
                  color: Color(kGenchiLightOrange),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Pay Applicant(s)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(
              height: 10,
            ),

            ///KEEP
            TaskDetailsSection(
              task: currentTask,
              linkOpen: _onOpenLink,
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

class ChangeJobStatus extends StatefulWidget {
  Future applicantsFuture;

  ChangeJobStatus({@required this.applicantsFuture});

  @override
  _ChangeJobStatusState createState() => _ChangeJobStatusState();
}

class _ChangeJobStatusState extends State<ChangeJobStatus> {
  bool firstPage = true;

  Map<String, bool> isSelected = {};

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: modalBottomSheetContainerDecoration,
        child: AnimatedCrossFade(
          crossFadeState:
              firstPage ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 300),
          firstChild: Padding(
            padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Flexible(
                        child: Center(
                          child: Text(
                            'What would you like to change the job status to?',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Icon(Icons.close),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                  height: 1,
                ),
                FlatButton(
                    height: MediaQuery.of(context).size.height * 0.12,
                    onPressed: () {
                      firstPage = false;
                      setState(() {});
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'IN PROGRESS',
                        style: TextStyle(
                          color: Color(kGreen),
                          fontSize: 25,
                        ),
                      ),
                    )),
                Divider(
                  thickness: 1,
                  height: 1,
                ),
                FlatButton(
                    height: MediaQuery.of(context).size.height * 0.12,
                    onPressed: () {},
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'COMPLETE',
                        style: TextStyle(
                          color: Color(kRed),
                          fontSize: 25,
                        ),
                      ),
                    )),
                Divider(
                  thickness: 1,
                  height: 1,
                ),
              ],
            ),
          ),
          secondChild: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      child: Icon(Icons.arrow_back_ios),
                      onTap: () {
                        setState(() {
                          firstPage = true;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Center(
                        child: Text(
                          'Which applicant(s) have you selected?',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 1,
                thickness: 1,
              ),

              //TODO: display applicants
              //TODO: allow selectability

              FutureBuilder(
                future: widget.applicantsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgress();
                  }

                  final List<Map<String, dynamic>> applicationAndApplicants =
                      snapshot.data;

                  if (applicationAndApplicants.isEmpty) {
                    return Text('There are no applicants yet');
                    //TODO: add something for if there are no applicants
                    // return Container(
                    //   color: Color(kGenchiCream),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 15),
                    //     child: ListTile(
                    //       contentPadding:
                    //       const EdgeInsets.symmetric(horizontal: 5),
                    //       tileColor: Color(kGenchiCream),
                    //       leading: ListDisplayPicture(
                    //         imageUrl: currentUser.displayPictureURL,
                    //         height: 56,
                    //       ),
                    //       title: Text(
                    //         'No Applicants Yet',
                    //         style: TextStyle(
                    //           color: Colors.black,
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //       onTap: () {
                    //         //TODO: route through to hirer's profile
                    //       },
                    //     ),
                    //   ),
                    // );
                  }

                  //TODO: maybe make a function for this?

                  ///First create messageListItems for each chat
                  List<Widget> applicantWidgets = [];

                  for (Map<String, dynamic> applicationAndApplicant
                      in applicationAndApplicants) {
                    TaskApplication taskApplication =
                        applicationAndApplicant['application'];
                    GenchiUser applicant = applicationAndApplicant['applicant'];

                    Widget userWidget = GestureDetector(
                      onTap: () {
                        if (isSelected[applicant.id] != null) {
                          isSelected[applicant.id] = !isSelected[applicant.id];
                        } else {
                          isSelected[applicant.id] = true;
                        }

                        setState(() {});
                      },
                      child: Container(
                        color: isSelected[applicant.id] == null
                            ? Colors.transparent
                            : isSelected[applicant.id]
                                ? Colors.black12
                                : Colors.transparent,
                        child: Stack(
                          alignment: AlignmentDirectional.centerEnd,
                          children: [
                            UserCard(
                                user: applicant, enabled: false, onTap: () {}),
                            if(isSelected[applicant.id] != null && isSelected[applicant.id] != false) Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.check,
                                  size: 30,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                    //TODO: create new type of user

                    applicantWidgets.add(userWidget);
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: applicantWidgets,
                  );
                },
              ),

              Center(
                child: RoundedButton(
                    buttonTitle: 'Choose Applicant(s)',
                    buttonColor: Color(kGenchiLightGreen),
                    fontColor: Colors.black,
                    elevation: false,

                    //TODO: add in functionality here
                    onPressed: () {}),
              ),
            ],
          ),
        ));
  }
}
