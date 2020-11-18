import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
            barTitle: 'Post Job',
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
                      hintText: 'Summary of the job',
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          height: 30.0,
                        ),
                        Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
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
                      field: 'Job Timings',
                      onChanged: (value) {
                        date = value;
                        changesMade = true;
                      },
                      textController: dateController,
                      hintText: 'The timeframe of the job',
                    ),
                    EditAccountField(
                      field: 'Details',
                      onChanged: (value) {
                        details = value;
                        changesMade = true;
                      },
                      textController: detailsController,
                      hintText: 'Provide further details of the job, urls etc.',

                    ),
                    EditAccountField(
                      field: 'Incentive',
                      onChanged: (value) {
                        price = value;
                        changesMade = true;
                      },
                      textController: priceController,
                      hintText: 'Payment, experience, volunteering etc.',

                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: RoundedButton(
                        buttonTitle: 'POST',
                        buttonColor: Color(kGenchiLightOrange),
                        fontColor: Colors.black,
                        onPressed: () async {
                          bool post = await showYesNoAlert(
                              context: context, title: 'Post job?');

                          if (post) {
                            setState(() {
                              showSpinner = true;
                            });

                            await analytics.logEvent(name: 'job_created');

                            await firestoreAPI.addTask(
                                task: Task(
                                    title: title,
                                    date: date,
                                    details: details,
                                    service: serviceController.text,
                                    time: Timestamp.now(),
                                    status: 'Vacant',
                                    price: price,
                                    hirerId: authProvider.currentUser.id),
                                hirerId: authProvider.currentUser.id);

                            await authProvider.updateCurrentUserData();
                            setState(() {
                              showSpinner = false;
                            });
                            Navigator.of(context).pop();
                          }
                        },
                      ),
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
