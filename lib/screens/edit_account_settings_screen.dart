import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/snackbars.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/user.dart';

import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class EditAccountSettingsScreen extends StatefulWidget {
  static const id = "edit_account_settings_screen";

  @override
  _EditAccountSettingsScreen createState() => _EditAccountSettingsScreen();
}

class _EditAccountSettingsScreen extends State<EditAccountSettingsScreen> {
  bool changesMade = false;
  final FirestoreAPIService fireStoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  bool showSpinner = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController accountTypeTextController = TextEditingController();
  TextEditingController universityTextController = TextEditingController();

  Future<bool> _onWillPop() async {
    if (changesMade) {
      bool discard = await showYesNoAlert(
          context: context, title: 'Are you sure you want to discard changes?');
      if (!discard) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    GenchiUser user =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    nameController.text = user.name;
    emailController.text = user.email;
    accountTypeTextController.text = user.accountType;
    universityTextController.text = user.university;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    accountTypeTextController.dispose();
    universityTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    GenchiUser currentUser = authProvider.currentUser;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Text(
              'Edit Account',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(kGenchiGreen),
            elevation: 2.0,
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
                  await fireStoreAPI.updateUser(
                      user: GenchiUser(
                        name: nameController.text,
                        email: emailController.text,
                        accountType: accountTypeTextController.text,
                        university: universityTextController.text,
                      ),
                      uid: currentUser.id);

                  ///If the user has changed their name just update it in the auth section
                  if (nameController.text != currentUser.name) {
                    await authProvider.updateCurrentUserName(
                        name: nameController.text);
                  }
                  await authProvider.updateCurrentUserData();

                  setState(() {
                    changesMade = false;
                    showSpinner = false;
                  });
                  Navigator.pop(context);
                },
              )
            ],
          ),
          body: Builder(
            builder: (BuildContext context) {
              return ModalProgressHUD(
                inAsyncCall: showSpinner,
                progressIndicator: CircularProgress(),
                child: ListView(
                  padding: EdgeInsets.all(15.0),
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          height: 30.0,
                        ),
                        //TODO: look at the below, for now just assuming that people can't switch their account types once made
                        EditAccountField(
                          field: "Account Type",
                          isEditable: false,
                          onChanged: (value) {
                            // changesMade = true;
                          },
                          textController: accountTypeTextController,
                        ),

                        // Text(
                        //   'Account Type',
                        //   style: TextStyle(
                        //     fontSize: 20.0,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                        // SizedBox(height: 5.0),
                        // PopupMenuButton(
                        //     elevation: 1,
                        //     child: Container(
                        //       decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.all(
                        //               Radius.circular(32.0)),
                        //         border: Border.all(color: Colors.black)
                        //
                        //       ),
                        //       child: Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //             vertical: 12.0, horizontal: 20.0),
                        //         child: Text(
                        //           accountTypeTextController.text,
                        //           style: TextStyle(
                        //             fontSize: 18,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     itemBuilder: (_) {
                        //       List<PopupMenuItem<String>> items = [
                        //       ];
                        //       for (String accountType
                        //       in GenchiUser().accessibleAccountTypes) {
                        //         items.add(
                        //           new PopupMenuItem<String>(
                        //               child: Text(accountType),
                        //               value: accountType),
                        //         );
                        //       }
                        //       return items;
                        //     },
                        //     onSelected: (value) async {
                        //       if (value != accountTypeTextController.text && hasServiceProfiles) {
                        //         bool change = await showYesNoAlert(
                        //             context: context,
                        //             title:
                        //             'Are you sure you want to change account type?',
                        //             body:
                        //             'Doing this will remove any other service accounts associated with this account.');
                        //
                        //         if (change) {
                        //           changesMade = true;
                        //           accountTypeTextController.text = value;
                        //           setState(() {});
                        //         }
                        //       } else {
                        //         changesMade = true;
                        //         accountTypeTextController.text = value;
                        //         setState(() {});
                        //       }
                        //     }),
                      ],
                    ),
                    if (currentUser.accountType != 'Company')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            height: 30.0,
                          ),
                          Text(
                            'University',
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
                                    universityTextController.text,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder: (_) {
                                List<PopupMenuItem<String>> items = [];
                                for (String accountType
                                    in GenchiUser().accessibleUniversities) {
                                  items.add(
                                    new PopupMenuItem<String>(
                                        child: Text(accountType),
                                        value: accountType),
                                  );
                                }
                                return items;
                              },
                              onSelected: (value) {
                                changesMade = true;
                                universityTextController.text = value;

                                setState(() {});
                              }),
                        ],
                      ),
                    EditAccountField(
                      field: "Name",
                      onChanged: (value) {
                        //Update name
                        changesMade = true;
                      },
                      textController: nameController,
                    ),
                    EditAccountField(
                      field: "Email",
                      isEditable: false,
                      onChanged: (value) {
                        changesMade = true;
                      },
                      textController: emailController,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Divider(
                      height: 10,
                    ),
                    Center(
                      child: RoundedButton(
                        buttonColor: Color(kGenchiBlue),
                        buttonTitle: "Change Password",
                        elevation: false,
                        onPressed: () async {
                          bool forgotPassword = await showYesNoAlert(
                              context: context,
                              title: 'Send reset password email?');

                          if (forgotPassword) {
                            setState(() => showSpinner = true);

                            await authProvider.sendResetEmail(
                                email: currentUser.email);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(kForgotPasswordSnackbar);

                            setState(() => showSpinner = false);
                          }
                        },
                      ),
                    ),
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
