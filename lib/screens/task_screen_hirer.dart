import 'dart:io' show Platform;
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
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:genchi_app/models/task.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      Map response = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: modalBottomSheetBorder,
                        builder: (context) => ChangeJobStatus(
                          applicantsFuture: applicantsFuture,
                          currentTask: currentTask,
                        ),
                      );

                      print(response);

                      if (response != null ||
                          response['status'] != currentTask.status) {
                        if (response['status'] == 'Vacant') {
                          ///Set applicant lists to empty
                          currentTask.unsuccessfulApplications = [];
                          currentTask.successfulApplications = [];

                          ///Update the task status
                          currentTask.status = 'Vacant';

                          ///Update in firestore
                          await firestoreAPI.updateTask(
                              task: currentTask, taskId: currentTask.taskId);
                        } else if (response['status'] == 'InProgress') {
                          ///Check if the status is moving from vacant to inProgress
                          ///if it is add the selected and unselected applicants the task before updating
                          if (currentTask.status == 'Vacant') {
                            ///Add successful applicants to the current Task list
                            currentTask.successfulApplications =
                                response['selectedApplicationIds'];

                            ///filter our the unsuccessful applicants and add to the Task list
                            List unsuccessfulApplications = [];
                            for (String id in currentTask.applicationIds) {
                              if (!response['selectedApplicationIds']
                                  .contains(id))
                                unsuccessfulApplications.add(id);
                            }
                            currentTask.unsuccessfulApplications =
                                unsuccessfulApplications;
                          }

                          ///Update changes
                          currentTask.status = 'InProgress';

                          ///Update in firestore
                          await firestoreAPI.updateTask(
                              task: currentTask, taskId: currentTask.taskId);
                        } else if (response['status'] == 'Completed') {
                          ///Update the task status
                          currentTask.status = 'Completed';

                          ///Update in firestore
                          await firestoreAPI.updateTask(
                              task: currentTask, taskId: currentTask.taskId);
                        }
                        setState(() {});
                      }
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
                        enabled: false,
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
                        onTap: () {},
                      ),
                    ),
                  );
                }

                ///First create messageListItems for each chat
                List<Widget> successfullChatWidgets = [];
                List<Widget> unSuccessfullChatWidgets = [];

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

                  ///Add into the correct section depending on whether the applicant is successful or not.
                  currentTask.unsuccessfulApplications
                          .contains(taskApplication.applicationId)
                      ? unSuccessfullChatWidgets.add(chatWidget)
                      : successfullChatWidgets.add(chatWidget);
                }

                return HirerTaskApplicants(
                  task: currentTask,
                  subtitleText:
                      '${currentTask.applicationIds.length} applicant${currentTask.applicationIds.length == 1 ? '' : 's'}',
                  hasUnreadMessage: hirerHasUnreadNotification,
                  successfulMessages: successfullChatWidgets,
                  unSuccessfulMessages: unSuccessfullChatWidgets,
                  hirer: currentUser,
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentTask.viewedIds.length.toString() + ' views',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey
                    )),
              ],
            ),
            SizedBox(
              height: 10,
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
              style: TextStyle(
                  fontSize: 22,
                  color: currentTask.status == 'Vacant'
                      ? Color(kPurple)
                      : (currentTask.status == 'InProgress'
                          ? Color(kGreen)
                          : Color(kRed))),
            ),
            SizedBox(
              height: 10,
            ),

            ///Show "pay applicant" button
            if (currentTask.status != 'Vacant')
              Builder(
                builder: (context) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height:
                          (MediaQuery.of(context).size.width * 0.6 - 15) * 0.2,
                      decoration: BoxDecoration(
                        color: Color(kGenchiLightOrange),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: FlatButton(
                          onPressed: () async {
                            bool payApplicants = await showYesNoAlert(
                                context: context, title: 'Pay Applicants?');

                            if (payApplicants != null) {
                              Scaffold.of(context)
                                  .showSnackBar(kDevelopmentFeature);
                              await analytics.logEvent(
                                  name: 'pay_button_pressed',
                                  parameters: {'response': payApplicants});
                            }
                          },
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Pay Applicant(s)',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
  Task currentTask;

  ChangeJobStatus(
      {@required this.applicantsFuture, @required this.currentTask});

  @override
  _ChangeJobStatusState createState() => _ChangeJobStatusState();
}

class _ChangeJobStatusState extends State<ChangeJobStatus> {
  bool firstPage = true;

  Map<String, bool> isSelected = {};
  Map response = {"status": "", "selectedApplicationIds": []};

  bool hasApplicants = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: modalBottomSheetContainerDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(builder: (context) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: modalBottomSheetContainerDecoration,
                child: AnimatedCrossFade(
                  crossFadeState: firstPage
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
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

                        ///Only choose the options status that the current status is not
                        if (widget.currentTask.status != 'Vacant')
                          FlatButton(
                              height: MediaQuery.of(context).size.height * 0.12,
                              onPressed: () async {
                                bool changeStatus = await showYesNoAlert(
                                    context: context,
                                    title:
                                        'Open the job for more applications?');

                                if (changeStatus) {
                                  response['status'] = 'Vacant';
                                  Navigator.pop(context, response);
                                }
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'ACCEPTING APPLICATIONS',
                                  style: TextStyle(
                                    color: Color(kPurple),
                                    fontSize: 25,
                                  ),
                                ),
                              )),
                        if (widget.currentTask.status != 'Vacant')
                          Divider(
                            thickness: 1,
                            height: 1,
                          ),
                        if (widget.currentTask.status != 'InProgress')
                          FlatButton(
                              height: MediaQuery.of(context).size.height * 0.12,
                              onPressed: () async {
                                ///If the task is completed, we don't need to choose applicants
                                if (widget.currentTask.status == 'Completed') {
                                  bool changeStatus = await showYesNoAlert(
                                      context: context,
                                      title: "Move job back to in progress?");

                                  if (changeStatus) {
                                    response['status'] = 'InProgress';

                                    response['selectedApplicationIds'] = widget
                                        .currentTask.successfulApplications;
                                    Navigator.pop(context, response);
                                  }
                                } else {
                                  ///Choose applications
                                  firstPage = false;
                                  setState(() {});
                                }
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
                        if (widget.currentTask.status != 'InProgress')
                          Divider(
                            thickness: 1,
                            height: 1,
                          ),
                        if (widget.currentTask.status != 'Completed')
                          FlatButton(
                              height: MediaQuery.of(context).size.height * 0.12,
                              onPressed: () async {
                                bool completed = await showYesNoAlert(
                                    context: context,
                                    title: 'Mark job as completed?');

                                if (completed) {
                                  response['status'] = 'Completed';
                                  Navigator.pop(context, response);
                                }
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'COMPLETED',
                                  style: TextStyle(
                                    color: Color(kRed),
                                    fontSize: 25,
                                  ),
                                ),
                              )),
                        if (widget.currentTask.status != 'Completed')
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
                                  'Which applicant(s) do you want to select?',
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
                      FutureBuilder(
                        future: widget.applicantsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgress();
                          }

                          final List<Map<String, dynamic>>
                              applicationAndApplicants = snapshot.data;

                          if (applicationAndApplicants.isEmpty) {
                            ///Response if there are no applicants
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text(
                                  'No Applicants Yet',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }

                          ///First create messageListItems for each chat
                          List<Widget> applicantWidgets = [];

                          for (Map<String, dynamic> applicationAndApplicant
                              in applicationAndApplicants) {
                            hasApplicants = true;
                            TaskApplication taskApplication =
                                applicationAndApplicant['application'];
                            GenchiUser applicant =
                                applicationAndApplicant['applicant'];

                            Widget userWidget = GestureDetector(
                              onTap: () {
                                if (isSelected[taskApplication.applicationId] !=
                                    null) {
                                  isSelected[taskApplication.applicationId] =
                                      !isSelected[
                                          taskApplication.applicationId];
                                } else {
                                  isSelected[taskApplication.applicationId] =
                                      true;
                                }

                                setState(() {});
                              },
                              child: Container(
                                color: isSelected[
                                            taskApplication.applicationId] ==
                                        null
                                    ? Colors.transparent
                                    : isSelected[taskApplication.applicationId]
                                        ? Colors.black12
                                        : Colors.transparent,
                                child: Stack(
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: [
                                    UserCard(
                                        user: applicant,
                                        enabled: false,
                                        onTap: () {}),
                                    if (isSelected[taskApplication
                                                .applicationId] !=
                                            null &&
                                        isSelected[taskApplication
                                                .applicationId] !=
                                            false)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 0),
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

                            applicantWidgets.add(userWidget);
                          }

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: applicantWidgets,
                          );
                        },
                      ),
                      if (hasApplicants)
                        Center(
                          child: RoundedButton(
                              buttonTitle: 'Choose Applicant(s)',
                              buttonColor: Color(kGenchiLightGreen),
                              fontColor: Colors.black,
                              elevation: false,
                              onPressed: () async {
                                print(isSelected);

                                if (isSelected.containsValue(true)) {
                                  bool chosen = await showYesNoAlert(
                                      context: context,
                                      title: 'Select applicant(s)?');

                                  if (chosen) {
                                    for (String value in isSelected.keys) {
                                      if (isSelected[value]) {
                                        response['selectedApplicationIds']
                                            .add(value);
                                      }
                                    }
                                    response['status'] = 'InProgress';
                                    Navigator.pop(context, response);
                                  }
                                } else {
                                  Scaffold.of(context)
                                      .showSnackBar(kNoApplicantsSelected);
                                }
                              }),
                        ),
                    ],
                  ),
                ));
          }),
        ));
  }
}
