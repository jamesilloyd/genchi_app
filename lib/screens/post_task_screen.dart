import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController applicationLinkController = TextEditingController();

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  void initState() {
    super.initState();

    GenchiUser currentUser =
        Provider
            .of<AuthenticationService>(context, listen: false)
            .currentUser;
    if (currentUser.draftJob.isNotEmpty) {
      Task draftJob = Task.fromMap(currentUser.draftJob);
      titleController.text = draftJob.title;
      priceController.text = draftJob.price;
      detailsController.text = draftJob.details;
      dateController.text = draftJob.date;
      serviceController.text = draftJob.service;
      applicationLinkController.text = draftJob.applicationLink;
    } else {
      serviceController.text = 'Other';
    }
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
            service: serviceController.text,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          height: 30.0,
                        ),
                        Text(
                          'Type of Opportunity',
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
                    EditAccountField(
                      field: 'Incentive',
                      onChanged: (value) {
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
                          ///Ask the user is they want to post
                          bool post = await showYesNoAlert(
                              context: context, title: 'Post opportunity?');

                          if (post) {
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
                              ///Link was valid
                              await analytics.logEvent(name: 'job_created');

                              await firestoreAPI.addTask(
                                  task: Task(
                                      title: titleController.text,
                                      date: dateController.text,
                                      details: detailsController.text,
                                      service: serviceController.text,
                                      time: Timestamp.now(),
                                      status: 'Vacant',
                                      linkApplicationType: linkApplicationType,
                                      applicationLink:
                                      applicationLinkController.text,
                                      price: priceController.text,
                                      hirerId: authProvider.currentUser.id),
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
