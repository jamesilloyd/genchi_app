import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/preferences.dart';
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

  List<Tag> allTags = List.generate(
      originalTags.length, (index) => Tag.fromTag(originalTags[index]));

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
    final accountService = Provider.of<AccountService>(context, listen: false);
    GenchiUser currentUser = accountService.currentAccount;

    for (String preference in currentUser.preferences) {
      bool found = false;

      ///if preference in opps values mark as true
      for (Tag tag in allTags) {
        if (preference == tag.databaseValue) {
          tag.selected = true;
          found = true;
        }
      }

      /// if nothing then add to other values
      if (!found) {
        allTags.add(Tag(
            databaseValue: preference,
            displayName: preference,
            selected: true,
            category: 'other'));
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
      onWillPop: args.isFromRegistration || args.isFromHome
          ? () async => false
          : _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading:
              args.isFromRegistration || args.isFromHome ? Container() : null,
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

                    for (Tag tag in allTags) {
                      if (tag.selected) allPreferences.add(tag.databaseValue);
                    }

                    currentUser.preferences = allPreferences;
                    currentUser.hasSetPreferences = true;

                    await firestoreAPI.updateUser(
                        uid: currentUser.id, user: currentUser);

                    await Provider.of<AuthenticationService>(context,
                            listen: false)
                        .updateCurrentUserData();

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
                  children: _chipBuilder(values: allTags, filter: 'type'),
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
                  children: _chipBuilder(values: allTags, filter: 'area'),
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
                  children: _chipBuilder(values: allTags, filter: 'spec'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageSelectionScreen extends StatefulWidget {
  List<Tag> allTags;

  HomePageSelectionScreen({@required this.allTags});

  @override
  _HomePageSelectionScreenState createState() =>
      _HomePageSelectionScreenState();
}

class _HomePageSelectionScreenState extends State<HomePageSelectionScreen> {
  bool chip1 = false;
  bool changesMade = false;

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
                label: Text(tag.databaseValue),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.06,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(flex: 1, child: SizedBox.shrink()),
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Filters',
                          textAlign: TextAlign.center,
                          style: kTitleTextStyle,
                        )),

                    //TODO: TEST THIS IS WORKING
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,15,0),
                          child: Text(
                            'Done',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                height: 0,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.74,
                child: ListView(
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Type',
                        textAlign: TextAlign.left,
                        style: kTitleTextStyle,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children:
                          _chipBuilder(values: widget.allTags, filter: 'type'),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Area',
                        style: kTitleTextStyle,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children:
                          _chipBuilder(values: widget.allTags, filter: 'area'),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Specification',
                        style: kTitleTextStyle,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children:
                          _chipBuilder(values: widget.allTags, filter: 'spec'),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                height: 0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        for (Tag tag in widget.allTags) {
                          tag.selected = false;
                          if (tag.category == 'other')
                            widget.allTags.remove(tag);
                        }
                        setState(() {});
                      },
                      child: Center(
                          child: Text(
                        'Clear all',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
