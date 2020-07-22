import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/drop_down_services.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';

import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/task.dart';
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
  String title;
  String details;
  String date;
  String price;
  String service;

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
                  setState(() {
                    showSpinner = true;
                  });

                  await fireStoreAPI.updateTask(
                      task: Task(
                          title: title,
                          service: serviceController.text,
                          details: details,
                          price: price,
                          date: date),
                      taskId: taskService.currentTask.taskId);

                  await taskService.updateCurrentTask(taskId: taskService.currentTask.taskId);

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
                    title = value;
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
                    SizedBox(
                      height: 50.0,
                      child: Container(
                        color: Color(kGenchiCream),
                        child: DropdownButton<String>(
                          value: serviceController.text != ''
                              ? serviceController.text : 'Other',
                          items: dropDownServiceItems(),
                          onChanged: (value) {
                            setState(() {
                              serviceController.text = value;
                              changesMade = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                EditAccountField(
                  field: "Job Timings",
                  textController: dateController,
                  hintText: 'The timeframe of the job',
                  onChanged: (value) {
                    date = value;
                    changesMade = true;
                  },
                ),
                EditAccountField(
                  field: "Details",
                  textController: detailsController,
                  hintText: 'Provide further details of the job',
                  onChanged: (value) {
                    details = value;
                    changesMade = true;
                  },
                ),
                EditAccountField(
                  field: "Price",
                  textController: priceController,
                  hintText: 'Estimated pay for the job',

                  onChanged: (value) {
                    price = value;
                    changesMade = true;
                  },
                ),
                SizedBox(height: 10),
                Divider(height: 10),
                RoundedButton(
                  buttonTitle: 'Delete job',
                  buttonColor: Color(kGenchiBlue),
                  elevation: false,
                  onPressed: ()async{

                    ///Ask user if they want to delete task
                    bool deleteTask = await showYesNoAlert(context: context, title: 'Are you sure you want to delete this job?');

                    if(deleteTask){
                      setState(() {
                        showSpinner = true;
                      });
                      await fireStoreAPI.deleteTask(task: taskService.currentTask);
                      await authProvider.updateCurrentUserData();

                      setState(() {
                        showSpinner = false;
                      });

                      Navigator.pushNamedAndRemoveUntil(context,
                          HomeScreen.id, (Route<dynamic> route) => false, arguments: HomeScreenArguments(startingIndex: 1));

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
