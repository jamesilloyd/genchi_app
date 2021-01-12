import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/add_image_screen.dart';
import 'package:genchi_app/services/time_formatting.dart';
import 'package:http/http.dart' as http;
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/models/task.dart';

import 'package:provider/provider.dart';

class PostTaskAndHirerScreen extends StatefulWidget {
  static const id = 'post_task_and_hirer_screen';

  @override
  _PostTaskAndHirerScreenState createState() => _PostTaskAndHirerScreenState();
}

class _PostTaskAndHirerScreenState extends State<PostTaskAndHirerScreen> {
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
  TextEditingController serviceController = TextEditingController();
  TextEditingController applicationLinkController = TextEditingController();

  TextEditingController categoryController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  void initState() {
    super.initState();
    firstDate = DateTime.now();
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

    categoryController.dispose();
    bioController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    final accountService = Provider.of<AccountService>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: BasicAppNavigationBar(
          barTitle: 'Post Opportunity and Hirer',
        ),
        body: Builder(
          builder: (BuildContext context) {
            return ModalProgressHUD(
              inAsyncCall: showSpinner,
              progressIndicator: CircularProgress(),
              child: ListView(
                padding: EdgeInsets.all(15.0),
                children: <Widget>[
                  Center(
                      child: Text(
                    'HIRER DETAILS',
                    style: TextStyle(fontSize: 20),
                  )),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0))),
                        builder: (context) => SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                child: AddImageScreen()),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        LargeDisplayPicture(
                          imageUrl:
                              accountService.currentAccount.displayPictureURL,
                          height: 0.25,
                          isEdit: true,
                        ),
                        Positioned(
                          right: (MediaQuery.of(context).size.width -
                                  MediaQuery.of(context).size.height * 0.25) /
                              2,
                          top: MediaQuery.of(context).size.height * 0.2,
                          child: new Container(
                            height: 30,
                            width: 30,
                            padding: EdgeInsets.all(2),
                            decoration: new BoxDecoration(
                                color: Color(kGenchiCream),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Color(0xff585858), width: 2)),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                  child: Icon(
                                Icons.edit,
                                size: 20,
                                color: Color(0xff585858),
                              )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  EditAccountField(
                    field: "Name",
                    onChanged: (value) {
                      //Update name
                      // changesMade = true;
                    },
                    textController: nameController,
                    hintText: 'Name',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: 30.0,
                      ),
                      Text(
                        'Category',
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
                                categoryController.text,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          itemBuilder: (_) {
                            List<PopupMenuItem<String>> items = [];
                            for (GroupType groupType in groupsList) {
                              var newItem = new PopupMenuItem(
                                child: Text(
                                  groupType.databaseValue,
                                ),
                                value: groupType.databaseValue,
                              );
                              items.add(newItem);
                            }
                            return items;
                          },
                          onSelected: (value) async {
                            setState(() {
                              categoryController.text = value;
                            });
                          }),
                    ],
                  ),
                  EditAccountField(
                    field: "About",
                    onChanged: (value) {
                      //Update name
                      // changesMade = true;
                    },
                    textController: bioController,
                    hintText: 'Describe what you do you.',
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                      child: Text(
                    'TASK DETAILS',
                    style: TextStyle(fontSize: 20),
                  )),
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
                        'Open Application?',
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
                              title: 'Open Application',
                              body:
                                  'Does this opportunity have a deadline to apply by?');
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
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                            ),
                          )),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Switch(
                              value: hasFixedDeadline,
                              inactiveTrackColor: Color(kGenchiLightGreen),
                              inactiveThumbColor: Color(kGenchiGreen),
                              onChanged: (value) {
                                setState(() {
                                  hasFixedDeadline = value;
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
                                  ? FontWeight.w500
                                  : FontWeight.w400,
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
                                        deadlineDateDT.microsecondsSinceEpoch);
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

                          if (linkApplicationType) {
                            try {
                              ///Test the link is real
                              var response = await http
                                  .head(applicationLinkController.text);
                              if (response.statusCode == 200) {
                                error = false;
                              } else {
                                error = true;
                              }
                            } catch (e) {
                              print(e);
                              error = true;
                            }
                          }
                          if (!error) {
                            ///Link was valid

                            await analytics.logEvent(name: 'job_created');

                            GenchiUser newHirer = GenchiUser(
                                name: nameController.text,
                                bio: bioController.text,
                                category: categoryController.text,
                                accountType: 'Individual',
                                admin: false);

                            await firestoreAPI.updateUser(
                                user: newHirer,
                                uid: accountService.currentAccount.id);

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
                                    hasFixedDeadline: hasFixedDeadline,
                                    applicationDeadline: deadlineDate,
                                    price: priceController.text,
                                    hirerId: accountService.currentAccount.id),
                                hirerId: accountService.currentAccount.id);

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
    );
  }
}
