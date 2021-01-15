import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'dart:io' show Platform;

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/post_reg_details_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:provider/provider.dart';

class CustomerNeedsScreen extends StatefulWidget {
  static const id = 'customer_needs_screen';

  @override
  _CustomerNeedsScreenState createState() => _CustomerNeedsScreenState();
}

class _CustomerNeedsScreenState extends State<CustomerNeedsScreen> {
  TextEditingController otherValuesController = TextEditingController();

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool chip1 = false;
  bool changesMade = false;

  //TODO: GET THESE FROM FIREBASE?
  List<Map> opportunityValues = [
    {'name': 'Easy paid work e.g. flyering', 'value': false},
    {'name': 'Career Experience', 'value': false},
    {'name': 'Skilled paid work e.g. product design', 'value': false},
    {'name': 'Interesting Projects', 'value': false},
    {'name': 'Academic Research', 'value': false},
    {'name': 'Scholarships / Awards', 'value': false},
  ];

  List<Map> areaValues = [
    {'name': 'STEM', 'value': false},
    {'name': 'Public Sector', 'value': false},
    {'name': 'Social Impact', 'value': false},
    {'name': 'Arts / Creative', 'value': false},
    {'name': 'Sustainability', 'value': false},
    {'name': 'Banking / Law / Consulting', 'value': false},
  ];

  List<Map> specValues = [
    {'name': 'Short term (within a week/a few days)', 'value': false},
    {'name': 'With companies', 'value': false},
    {'name': 'Long term (over several weeks)', 'value': false},
    {'name': 'With student groups', 'value': false},
    {'name': 'During term', 'value': false},
    {'name': 'Outside of term', 'value': false},
    {'name': 'With charities', 'value': false},
  ];

  List otherValues = [];

  List<Widget> _chipBuilder({@required List values}) {
    List<Widget> widgets = [];

    for (Map chip in values) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GestureDetector(
            onTap: () {
              changesMade = true;
              setState(() {
                chip['value'] = !chip['value'];
              });
            },
            child: Chip(
              label: Text(chip['name']),
              backgroundColor:
                  chip['value'] ? Color(kGenchiLightOrange) : Colors.black12,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _otherChipBuilder({@required List values}) {
    List<Widget> widgets = [];
    for (String chip in values) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
          child: Chip(
            label: Text(chip),
            backgroundColor: Color(kGenchiLightOrange),
            onDeleted: () {
              values.remove(chip);
              setState(() {});
            },
          ),
        ),
      );
    }

    return widgets;
  }

  @override
  void initState() {
    super.initState();
    final accountService = Provider.of<AccountService>(context, listen: false);
    GenchiUser currentUser = accountService.currentAccount;

    for (String preference in currentUser.preferences) {
      bool found = false;

      ///if prefernce in opps values mark as true
      for (Map value in opportunityValues) {
        if (preference == value['name']) {
          value['value'] = true;
          found = true;
        }
      }

      ///if prefernce in opps values mark as true
      for (Map value in areaValues) {
        if (preference == value['name']) {
          value['value'] = true;
          found = true;
        }
      }

      ///if prefernce in opps values mark as true
      for (Map value in specValues) {
        if (preference == value['name']) {
          value['value'] = true;
          found = true;
        }
      }

      /// if nothing then add to other values
      if (!found) {
        otherValues.add(preference);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    otherValuesController.dispose();
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
    final accountService = Provider.of<AccountService>(context);
    GenchiUser currentUser = accountService.currentAccount;

    final PreferencesScreenArguments args =
        ModalRoute.of(context).settings.arguments ??
            PreferencesScreenArguments();

    return WillPopScope(
      onWillPop: args.isFromRegistration || args.isFromHome ? () async => false : _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: args.isFromRegistration || args.isFromHome ? Container() : null,
          centerTitle: true,
          backgroundColor: Color(kGenchiGreen),
          title: Text(
            'Preferences',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          brightness: Brightness.light,
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: IconButton(
                onPressed: () async {
                  //TODO: do we need this?
                  bool save = await showYesNoAlert(
                      context: context, title: 'Save Changes?');

                  if (save) {
                    List allPreferences = [];

                    allPreferences.addAll(opportunityValues);
                    allPreferences.addAll(areaValues);
                    allPreferences.addAll(specValues);

                    List userPreferences = [];
                    userPreferences.addAll(otherValues);

                    for (Map preference in allPreferences) {
                      if (preference['value']) {
                        userPreferences.add(preference['name']);
                      }
                    }

                    currentUser.preferences = userPreferences;
                    currentUser.hasSetPreferences = true;

                    await firestoreAPI.updateUser(
                        uid: currentUser.id, user: currentUser);

                    await Provider.of<AuthenticationService>(context,listen:false).updateCurrentUserData();

                    if (args.isFromRegistration) {
                      ///Move on to the next page
                      Navigator.pushNamed(context, PostRegDetailsScreen.id);
                    } else {
                      ///Pop
                      Navigator.pop(context);
                    }
                  }
                },
                icon: Icon(
                  Platform.isIOS
                      ? CupertinoIcons.check_mark_circled
                      : Icons.check_circle_outline,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: ListView(
              children: [
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'What type of opportunities are you after?',
                        textAlign: TextAlign.center,
                        style: kTitleTextStyle,
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
                            title: 'Types of Opportunities',
                            body:
                                'Select the type of opportunities you are after and we will optimise our platform to get you these opportunities.');
                      },
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: _chipBuilder(values: opportunityValues),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'In what areas?',
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
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: _chipBuilder(values: areaValues),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: _chipBuilder(values: specValues),
                ),
                SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'Other?',
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
                              'Add any other criteria that is not listed above.');
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
                        decoration: kEditAccountTextFieldDecoration.copyWith(
                            hintText: 'Add any other criteria here...'),
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
                            if(otherValuesController.text != '') {
                              otherValues.add(otherValuesController.text);
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
                  children: _otherChipBuilder(values: otherValues),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
