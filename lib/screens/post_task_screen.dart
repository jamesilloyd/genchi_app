
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/drop_down_services.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/task.dart';

import 'package:provider/provider.dart';

class PostTaskScreen extends StatefulWidget {
  static const id = 'post_task_screen';

  @override
  _PostTaskScreenState createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen> {
  bool changesMade = false;
  bool showSpinner = false;
  String title;
  String date;
  String details;
  String price;

  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController serviceController = TextEditingController();

  FirestoreAPIService firestoreAPI = FirestoreAPIService();


  @override
  void initState() {
    super.initState();
    serviceController.text = 'Other';
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
    final authProvider = Provider.of<AuthenticationService>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: BasicAppNavigationBar(
            barTitle: 'Post Task',
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
                        title = value;
                        changesMade = true;
                      },
                      textController: titleController,
                      hintText: 'Summary of the task',
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
                            color: Color(kGenchiBlue),
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
                      field: 'Date',
                      onChanged: (value) {
                        date = value;
                        changesMade = true;
                      },
                      textController: dateController,
                      hintText: 'The timeframe of the task',
                    ),
                    EditAccountField(
                      field: 'Details',
                      onChanged: (value) {
                        details = value;
                        changesMade = true;
                      },
                      textController: detailsController,
                      hintText: 'Provide further details of the task',

                    ),
                    EditAccountField(
                      field: 'Price',
                      onChanged: (value) {
                        price = value;
                        changesMade = true;
                      },
                      textController: priceController,
                      hintText: 'Estimated pay for the task',

                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RoundedButton(
                      buttonTitle: 'POST',
                      buttonColor: Color(kGenchiBlue),
                      fontColor: Color(kGenchiCream),
                      onPressed: () async {
                        bool post = await showYesNoAlert(
                            context: context, title: 'Post task?');

                        if (post) {
                          setState(() {
                            showSpinner = true;
                          });
                          await firestoreAPI.addTask(
                              task: Task(
                                  title: title,
                                  date: date,
                                  details: details,
                                  service: serviceController.text,
                                  time: Timestamp.now(),
                                  price: price,
                                  hirerId: authProvider.currentUser.id),
                              uid: authProvider.currentUser.id);

                          await authProvider.updateCurrentUserData();
                          setState(() {
                            showSpinner = false;
                          });
                          Navigator.of(context).pop();
                        }
                      },
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
