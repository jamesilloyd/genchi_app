import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/drop_down_services.dart';
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


  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Task task = Provider.of<TaskService>(context, listen: false).currentTask;
    titleController.text = task.title;
    detailsController.text = task.details;
    dateController.text = task.date;
    serviceController.text = task.service;
    priceController.text = task.price;
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    detailsController.dispose();
    dateController.dispose();
    serviceController.dispose();
    priceController.dispose();
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
            title: Text(
              'Edit Job',
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
              IconButton(
                icon: Icon(
                  Platform.isIOS
                      ? CupertinoIcons.check_mark_circled
                      : Icons.check_circle_outline,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () async {
                  analytics.logEvent(name: 'task_top_save_changes_button_pressed');
                  setState(() {
                    showSpinner = true;
                  });

                  await fireStoreAPI.updateTask(
                      task: Task(
                          title: titleController.text,
                          service: serviceController.text,
                          details: detailsController.text,
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
                },
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
                  hintText: 'Summary of the job',
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              borderRadius: BorderRadius.all(
                                  Radius.circular(32.0)),
                              border: Border.all(color: Colors.black)

                          ),
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
                          List<PopupMenuItem<String>> items = [
                          ];
                          for (Service serviceType in servicesList) {
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
                EditAccountField(
                  field: "Job Timings",
                  textController: dateController,
                  hintText: 'The timeframe of the job',
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                EditAccountField(
                  field: "Details",
                  textController: detailsController,
                  hintText: 'Provide further details of the job, urls etc.',
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
                RoundedButton(
                  buttonTitle: 'Save changes',
                  buttonColor: Color(kGenchiGreen),
                  onPressed: () async {
                    analytics.logEvent(name: 'task_bottom_save_changes_button_pressed');
                    setState(() {
                      showSpinner = true;
                    });

                    await fireStoreAPI.updateTask(
                        task: Task(
                            title: titleController.text,
                            service: serviceController.text,
                            details: detailsController.text,
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

                  },
                ),
                RoundedButton(
                  buttonTitle: 'Delete job',
                  buttonColor: Color(kGenchiBlue),
                  elevation: false,
                  onPressed: () async {
                    ///Ask user if they want to delete task
                    bool deleteTask = await showYesNoAlert(
                        context: context,
                        title: 'Are you sure you want to delete this job?');

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

                      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id,
                          (Route<dynamic> route) => false,
                          arguments: HomeScreenArguments(startingIndex: 1));
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
