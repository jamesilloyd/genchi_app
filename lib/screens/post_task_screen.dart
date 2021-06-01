import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/models/preferences.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/screens/jobs_screen.dart';
import 'package:genchi_app/screens/pay_genchi_screen.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:http/http.dart' as http;
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/models/task.dart';

import 'package:provider/provider.dart';

class PostTaskScreen extends StatefulWidget {
  static const id = 'post_task_screen';

  @override
  _PostTaskScreenState createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  bool changesMade = false;
  bool showSpinner = false;
  bool linkApplicationType = false;
  bool hasFixedDeadline = true;

  Timestamp deadlineDate;
  DateTime firstDate;

  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController applicationLinkController = TextEditingController();

  TextEditingController otherValuesController = TextEditingController();

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  List<Tag> allTags = List.generate(
      originalTags.length, (index) => Tag.fromTag(originalTags[index]));

  //TODO: find a better way of doing this
  List<Tag> uniTags = [
    Tag(
        databaseValue: 'Cambridge',
        displayName: 'Cambridge',
        selected: false,
        category: 'University'),
    Tag(
        databaseValue: 'Harvard',
        displayName: 'Harvard',
        selected: false,
        category: 'University'),
    Tag(
        databaseValue: 'MIT',
        displayName: 'MIT',
        selected: false,
        category: 'University'),
  ];

  List<Widget> _chipBuilder(
      {@required List<Tag> values, @required String filter}) {
    List<Widget> widgets = [];

    for (Tag tag in values) {
      if (tag.category == filter) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: GestureDetector(
              onTap: () {
                changesMade = true;
                setState(() {
                  tag.selected = !tag.selected;
                });
              },
              child: Chip(
                label: Text(tag.displayName),
                backgroundColor:
                    tag.selected ? Color(kGenchiLightOrange) : Colors.black12,
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  List<Widget> _otherChipBuilder({@required List<Tag> values}) {
    List<Widget> widgets = [];
    for (Tag tag in values) {
      if (tag.category == 'other') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
            child: Chip(
              label: Text(tag.displayName),
              backgroundColor: Color(kGenchiLightOrange),
              onDeleted: () {
                allTags.remove(tag);
                setState(() {});
              },
            ),
          ),
        );
      }
    }

    return widgets;
  }

  @override
  void initState() {
    super.initState();

    firstDate = DateTime.now();

    GenchiUser currentUser =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    if (currentUser.draftJob.isNotEmpty) {
      Task draftJob = Task.fromMap(currentUser.draftJob);
      titleController.text = draftJob.title;
      priceController.text = draftJob.price;
      detailsController.text = draftJob.details;
      dateController.text = draftJob.date;
      applicationLinkController.text = draftJob.applicationLink;
      linkApplicationType = draftJob.linkApplicationType;
      hasFixedDeadline = draftJob.hasFixedDeadline;
      deadlineDate = draftJob.applicationDeadline;
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    detailsController.dispose();
    dateController.dispose();
    priceController.dispose();
    applicationLinkController.dispose();
    otherValuesController.dispose();
  }

  Future<bool> _onWillPop() async {
    ///Default to close the draft if no changes have been made
    bool finishLater = true;
    if (changesMade) {
      finishLater = await showYesNoAlert(
          context: context,
          title: 'Finish later?',
          body: 'The post you started will be here when you return.');
      if (finishLater) {
        ///Get the current user
        final authProvider =
            Provider.of<AuthenticationService>(context, listen: false);
        GenchiUser currentUser = authProvider.currentUser;

        ///Save the text controller values as a draft to the current user
        currentUser.draftJob = Task(
                title: titleController.text,
                details: detailsController.text,
                date: dateController.text,
                applicationLink:
                    applicationLinkController.text.replaceAll(' ', ''),
                linkApplicationType: linkApplicationType,
                hasFixedDeadline: hasFixedDeadline,
                applicationDeadline: deadlineDate,
                price: priceController.text)
            .toJson();

        ///Update the current user in firestore
        await firestoreAPI.updateUser(user: currentUser, uid: currentUser.id);

        ///Update the user so the new details are stored in the session
        await authProvider.updateCurrentUserData();
      }
    }
    return finishLater;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: BasicAppNavigationBar(
            barTitle: 'Post Opportunity',
          ),
          body: Builder(
            builder: (BuildContext context) {
              return ModalProgressHUD(
                inAsyncCall: showSpinner,
                progressIndicator: CircularProgress(),
                child: ListView(
                  padding: EdgeInsets.all(15.0),
                  children: <Widget>[
                    EditAccountField(
                      field: 'Title',
                      onChanged: (value) {
                        changesMade = true;
                      },
                      textController: titleController,
                      hintText: 'Summary of the opportunity',
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Application Style',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.help_outline_outlined,
                            size: 18,
                          ),
                          onTap: () async {
                            await showDialogBox(
                                context: context,
                                title: 'Application Style',
                                body:
                                    'In-App is used to allow users to apply in the app and create a chat with you. '
                                    '\n\nA Link application is used if you want to route the user away from the app to your recruitment destination.');
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              'In-App',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(kGenchiGreen),
                                fontSize: 20,
                                fontWeight: linkApplicationType
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                              ),
                            )),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Switch(
                                value: linkApplicationType,
                                inactiveTrackColor: Color(kGenchiLightGreen),
                                inactiveThumbColor: Color(kGenchiGreen),
                                onChanged: (value) {
                                  setState(() {
                                    linkApplicationType = value;
                                  });
                                }),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'Link',
                              style: TextStyle(
                                color: Color(kGenchiOrange),
                                fontSize: 20,
                                fontWeight: linkApplicationType
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            )),
                      ],
                    ),
                    AnimatedContainer(
                      height: linkApplicationType ? 80 : 0,
                      duration: Duration(milliseconds: 200),
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: linkApplicationType ? 1 : 0,
                        // duration: Duration(milliseconds: 200),
                        // height: linkApplicationType ? 0 : 100,
                        child: TextField(
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          maxLines: null,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.left,
                          onChanged: (value) {
                            changesMade = true;
                          },
                          controller: applicationLinkController,
                          decoration: kEditAccountTextFieldDecoration.copyWith(
                              hintText: 'Insert application link'),
                          cursorColor: Color(kGenchiOrange),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Fixed Deadline?',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.help_outline_outlined,
                            size: 18,
                          ),
                          onTap: () async {
                            await showDialogBox(
                                context: context,
                                title: 'Fixed Deadline',
                                body:
                                    'Does this opportunity have a deadline to apply by (Yes) or is the application open (No)?');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              'Yes',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(kGenchiGreen),
                                fontSize: 20,
                                fontWeight: hasFixedDeadline
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            )),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Switch(
                                value: !hasFixedDeadline,
                                inactiveTrackColor: Color(kGenchiLightGreen),
                                inactiveThumbColor: Color(kGenchiGreen),
                                onChanged: (value) {
                                  setState(() {
                                    hasFixedDeadline = !value;
                                  });
                                }),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: Color(kGenchiOrange),
                                fontSize: 20,
                                fontWeight: hasFixedDeadline
                                    ? FontWeight.w400
                                    : FontWeight.w500,
                              ),
                            )),
                      ],
                    ),
                    AnimatedContainer(
                      height: hasFixedDeadline ? 80 : 0,
                      duration: Duration(milliseconds: 200),
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: hasFixedDeadline ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Application Deadline',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                    border: Border.all(color: Colors.black)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                  child: Text(
                                    deadlineDate == null
                                        ? 'Select Date'
                                        : getApplicationDeadline(
                                            time: deadlineDate),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () async {
                                DateTime deadlineDateDT = await showDatePicker(
                                  context: context,
                                  initialDate: deadlineDate == null
                                      ? DateTime.now()
                                      : deadlineDate
                                                  .toDate()
                                                  .difference(firstDate)
                                                  .inMinutes >
                                              0
                                          ? deadlineDate.toDate()
                                          : DateTime.now(),
                                  firstDate: firstDate,
                                  lastDate:
                                      DateTime.now().add(Duration(days: 365)),
                                );

                                if (deadlineDateDT != null) {
                                  deadlineDate =
                                      Timestamp.fromMicrosecondsSinceEpoch(
                                          deadlineDateDT
                                              .microsecondsSinceEpoch);
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    EditAccountField(
                      field: 'Opportunity Timings',
                      onChanged: (value) {
                        changesMade = true;
                      },
                      textController: dateController,
                      hintText: 'The timeframe of the opportunity',
                    ),
                    EditAccountField(
                      field: 'Details',
                      onChanged: (value) {
                        changesMade = true;
                      },
                      textController: detailsController,
                      hintText:
                          'Provide further details of the opportunity, urls etc.',
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Students from which Universities can apply?',
                      textAlign: TextAlign.start,
                      style: kTitleTextStyle,
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children:
                          _chipBuilder(values: uniTags, filter: 'University'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'What type of opportunity is this?',
                          textAlign: TextAlign.start,
                          style: kTitleTextStyle,
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.help_outline_outlined,
                            size: 18,
                          ),
                          onTap: () async {
                            await showDialogBox(
                                context: context,
                                title: 'Types of Opportunities',
                                body:
                                    'Select the type of opportunities you are after and we will optimise our platform to get you these opportunities.');
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: _chipBuilder(values: allTags, filter: 'type'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'What area(s)?',
                          style: kTitleTextStyle,
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.help_outline_outlined,
                            size: 18,
                          ),
                          onTap: () async {
                            await showDialogBox(
                                context: context,
                                title: 'Areas',
                                body:
                                    'Select the areas you would like the opportunities to be in.');
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: _chipBuilder(values: allTags, filter: 'area'),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'What specifications?',
                          style: kTitleTextStyle,
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.help_outline_outlined,
                            size: 18,
                          ),
                          onTap: () async {
                            await showDialogBox(
                                context: context,
                                title: 'Specification',
                                body:
                                    'Select the constraints you want for these opportunities.');
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: _chipBuilder(values: allTags, filter: 'spec'),
                    ),
                    SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Text(
                        'Other tags?',
                        style: kTitleTextStyle,
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.help_outline_outlined,
                          size: 18,
                        ),
                        onTap: () async {
                          await showDialogBox(
                              context: context,
                              title: 'Other',
                              body:
                                  'Add any other tags that are not listed above.');
                        },
                      ),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            controller: otherValuesController,
                            decoration:
                                kEditAccountTextFieldDecoration.copyWith(
                                    hintText: 'Add any other tags here...'),
                            cursorColor: Color(kGenchiOrange),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 1,
                            child: RoundedButton(
                              onPressed: () {
                                if (otherValuesController.text != '') {
                                  allTags.add(Tag(
                                      displayName: otherValuesController.text,
                                      databaseValue: otherValuesController.text,
                                      selected: true,
                                      category: 'other'));
                                  otherValuesController.clear();
                                  changesMade = true;
                                  setState(() {});
                                }
                              },
                              buttonTitle: 'Add',
                              fontColor: Colors.black,
                              buttonColor: Color(kGenchiLightGreen),
                            ))
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: _otherChipBuilder(values: allTags),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: RoundedButton(
                          buttonTitle:
                              authProvider.currentUser.accountType != 'Company'
                                  ? 'POST'
                                  : 'Go to Payment',
                          buttonColor: Color(kGenchiLightOrange),
                          fontColor: Colors.black,
                          onPressed: () async {
                            ///Ask the user is they want to post
                            bool post = await showYesNoAlert(
                                context: context,
                                title: authProvider.currentUser.accountType ==
                                        'Company'
                                    ? 'Ready to pay'
                                    : 'Post opportunity?');

                            if (post) {
                              setState(() {
                                showSpinner = true;
                              });

                              ///Just check if the link is valid first
                              bool error = false;
                              String errorMessage = '';

                              if (linkApplicationType) {
                                try {
                                  ///Test the link is real
                                  var response = await http.head(Uri.parse(
                                      applicationLinkController.text
                                          .replaceAll(' ', '')));
                                  if (response.statusCode == 200) {
                                    error = false;
                                  } else {
                                    error = true;
                                  }
                                } catch (e) {
                                  print(e);
                                  error = true;
                                  errorMessage = 'Application Link Not Valid';
                                }
                              }

                              if (hasFixedDeadline && deadlineDate == null) {
                                error = true;
                                errorMessage =
                                    'Please set the application deadline date.';
                              }

                              bool selectedUni = false;
                              List universities = [];

                              for (Tag uni in uniTags) {
                                if (uni.selected == true) {
                                  selectedUni = true;
                                  universities.add(uni.databaseValue);
                                }
                              }
                              if (!selectedUni) {
                                error = true;
                                errorMessage = 'Please select a University';
                              }

                              if (!error) {
                                ///Link was valid
                                ///Collate all the tags
                                List taskTags = [];

                                for (Tag tag in allTags) {
                                  if (tag.selected)
                                    taskTags.add(tag.databaseValue);
                                }

                                Task task = Task(
                                    title: titleController.text,
                                    date: dateController.text,
                                    details: detailsController.text,
                                    time: Timestamp.now(),
                                    status: 'Vacant',
                                    linkApplicationType: linkApplicationType,
                                    applicationLink: applicationLinkController
                                        .text
                                        .replaceAll(' ', ''),
                                    hasFixedDeadline: hasFixedDeadline,
                                    universities: universities,
                                    applicationDeadline: deadlineDate,
                                    price: priceController.text,
                                    tags: taskTags,
                                    hirerId: authProvider.currentUser.id);

                                if (authProvider.currentUser.accountType ==
                                    'Company') {
                                  ///Route companies to the payment screen
                                  print('Company job posting');

                                  setState(() {
                                    showSpinner = false;
                                  });

                                  Navigator.pushNamed(
                                      context, PayGenchiScreen.id,
                                      arguments: PayGenchiScreenArguments(
                                          taskToPost: task));
                                } else {
                                  print('Non company job posting');
                                  await analytics.logEvent(name: 'job_created');

                                  await firestoreAPI.addTask(
                                      task: task,
                                      hirerId: authProvider.currentUser.id);

                                  ///If there is a draft saved in the user, delete it
                                  if (authProvider
                                      .currentUser.draftJob.isNotEmpty) {
                                    authProvider.currentUser.draftJob = {};
                                    await firestoreAPI.updateUser(
                                        user: authProvider.currentUser,
                                        uid: authProvider.currentUser.id);
                                  }

                                  ///update the user
                                  await authProvider.updateCurrentUserData();
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  Navigator.of(context).pop();
                                }
                              } else {
                                ///link was not valid

                                setState(() {
                                  showSpinner = false;
                                });

                                await showDialogBox(
                                  context: context,
                                  title: errorMessage,
                                );
                              }
                            }
                          }),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
