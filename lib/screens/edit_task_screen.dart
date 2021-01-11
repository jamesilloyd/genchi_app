import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';

import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class EditTaskScreen extends StatefulWidget {
  static const id = 'edit_task_screen';

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  bool changesMade = false;
  bool showSpinner = false;
  bool linkApplicationType = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController applicationLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Task task = Provider.of<TaskService>(context, listen: false).currentTask;
    titleController.text = task.title;
    detailsController.text = task.details;
    dateController.text = task.date;
    serviceController.text = task.service;
    priceController.text = task.price;
    applicationLinkController.text = task.applicationLink;
    linkApplicationType = task.linkApplicationType;
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    detailsController.dispose();
    dateController.dispose();
    serviceController.dispose();
    priceController.dispose();
    applicationLinkController.dispose();
  }

  final FirestoreAPIService fireStoreAPI = FirestoreAPIService();

  Future<bool> _onWillPop() async {
    if (changesMade) {
      bool discard = await showYesNoAlert(
          context: context, title: 'Are you sure you want to discard changes?');
      if (!discard) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);
    final authProvider = Provider.of<AuthenticationService>(context);
    FirebaseAnalytics analytics = FirebaseAnalytics();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            centerTitle: true,
            title: Text(
              'Edit Opportunity',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(kGenchiGreen),
            elevation: 1.0,
            brightness: Brightness.light,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: IconButton(
                  icon: Icon(
                    Platform.isIOS
                        ? CupertinoIcons.check_mark_circled
                        : Icons.check_circle_outline,
                    size: 30,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });

                    ///Just check if the link is valid first
                    bool error = false;

                    if(linkApplicationType) {
                      try {
                        ///Test the link is real
                        var response = await http
                            .head(applicationLinkController.text);
                        if (response.statusCode == 200) {
                          error = false;
                        }else{
                          error=true;
                        }
                      } catch (e) {
                        print(e);
                        error = true;
                      }
                    }
                    if (!error) {
                      ///link is valid

                      await fireStoreAPI.updateTask(
                          task: Task(
                              title: titleController.text,
                              service: serviceController.text,
                              details: detailsController.text,
                              linkApplicationType: linkApplicationType,
                              applicationLink: applicationLinkController.text,
                              price: priceController.text,
                              date: dateController.text),
                          taskId: taskService.currentTask.taskId);

                      await taskService.updateCurrentTask(
                          taskId: taskService.currentTask.taskId);

                      setState(() {
                        changesMade = false;
                        showSpinner = false;
                      });
                      Navigator.of(context).pop();
                    } else {
                      ///link was not valid

                      setState(() {
                        showSpinner = false;
                      });

                      await showDialogBox(
                          context: context,
                          title: 'Application Link Not Valid',
                          body:
                              'Enter a working application link before posting the job');
                    }
                  },
                ),
              )
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: CircularProgress(),
            child: ListView(
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
                EditAccountField(
                  field: "Title",
                  textController: titleController,
                  hintText: 'Summary of the opportunity',
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 30.0,
                    ),
                    Text(
                      'Service',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    PopupMenuButton(
                        elevation: 1,
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
                              serviceController.text,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        itemBuilder: (_) {
                          List<PopupMenuItem<String>> items = [];
                          for (Service serviceType in opportunityTypeList) {
                            var newItem = new PopupMenuItem(
                              child: Text(
                                serviceType.databaseValue,
                              ),
                              value: serviceType.databaseValue,
                            );
                            items.add(newItem);
                          }
                          return items;
                        },
                        onSelected: (value) async {
                          setState(() {
                            changesMade = true;
                            serviceController.text = value;
                          });
                        }),
                  ],
                ),
                SizedBox(
                  height: 20,
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
                            title: 'Application',
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
                      textCapitalization: TextCapitalization.sentences,
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
                          hintText:
                              'Insert application link'),
                      cursorColor: Color(kGenchiOrange),
                    ),
                  ),
                ),
                Text(
                  'Application Deadline',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Center(child: Text('Coming in next update')),
                EditAccountField(
                  field: "Opportunity Timings",
                  textController: dateController,
                  hintText: 'The timeframe of the opportunity',
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                EditAccountField(
                  field: "Details",
                  textController: detailsController,
                  hintText:
                      'Provide further details of the opportunity, urls etc.',
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                EditAccountField(
                  field: "Incentive",
                  textController: priceController,
                  hintText: 'Payment, experience, volunteering etc.',
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                SizedBox(height: 10),
                Divider(height: 10),
                Center(
                  child: RoundedButton(
                    buttonTitle: 'Delete opportunity',
                    buttonColor: Color(kGenchiBlue),
                    elevation: false,
                    onPressed: () async {
                      ///Ask user if they want to delete task
                      bool deleteTask = await showYesNoAlert(
                          context: context,
                          title:
                              'Are you sure you want to delete this opportunity?');

                      if (deleteTask) {
                        setState(() {
                          showSpinner = true;
                        });

                        ///Log in firebase analytics
                        await analytics.logEvent(name: 'job_deleted');

                        await fireStoreAPI.deleteTask(
                            task: taskService.currentTask);

                        await authProvider.updateCurrentUserData();

                        setState(() {
                          showSpinner = false;
                        });

                        Navigator.pushNamedAndRemoveUntil(context,
                            HomeScreen.id, (Route<dynamic> route) => false,
                            arguments: HomeScreenArguments(startingIndex: 1));
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
