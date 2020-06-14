import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
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
  bool showSpinner = false;
  String title;
  String date;
  String details;

  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController serviceController = TextEditingController();

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  servicePicker({@required TextEditingController controller}) {
    return Platform.isIOS
        ? iOSPicker(controller: controller)
        : androidDropdownButton(controller: controller);
  }

  DropdownButton<String> androidDropdownButton(
      {@required TextEditingController controller}) {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (Map serviceType in servicesListMap) {
      var newItem = DropdownMenuItem(
        child: Text(
          serviceType['name'],
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        value: serviceType['name'].toString(),
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
      value: controller.text != '' ? controller.text : 'Other',
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          controller.text = value;
        });
      },
    );
  }

  CupertinoPicker iOSPicker({@required TextEditingController controller}) {
    List<Text> pickerItems = [];
    for (Map serviceType in servicesListMap) {
      var newItem = Text(serviceType['name']);
      pickerItems.add(newItem);
    }

    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: servicesListMap.indexWhere((service) => service['name'] == 'Other'),
      ),
      backgroundColor: Color(kGenchiCream),
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        controller.text = pickerItems[selectedIndex].data;
      },
      children: pickerItems,
    );
  }

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
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: MyAppNavigationBar(
          barTitle: 'Post Task',
        ),
        body: Builder(
          builder: (BuildContext context) {
            return ModalProgressHUD(
              inAsyncCall: showSpinner,
              progressIndicator: CircularProgress(),
              child: ListView(
                padding: EdgeInsets.all(20.0),
                children: <Widget>[
                  EditAccountField(
                    field: 'Title',
                    onChanged: (value) {
                      title = value;
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
                        height: Platform.isIOS ? 100.0 : 50.0,
                        child: Container(
                          color: Color(kGenchiCream),
                          child: servicePicker(controller: serviceController),
                        ),
                      ),
                    ],
                  ),
                  EditAccountField(
                    field: 'Date',
                    onChanged: (value) {
                      date = value;
                    },
                    textController: dateController,
                    hintText: 'The timeframe of the task',
                  ),
                  EditAccountField(
                    field: 'Details',
                    onChanged: (value) {
                      details = value;
                    },
                    textController: detailsController,
                    hintText: 'Provide further details of the task',
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
    );
  }
}
