import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
    User user =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    nameController.text = user.name;
    emailController.text = user.email;
    accountTypeTextController.text = user.accountType;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    accountTypeTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;
    bool hasServiceProfiles = currentUser.providerProfiles.isNotEmpty;
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
                  await analytics.logEvent(
                      name: 'hirer_top_save_changes_button_pressed');

                  ///Check if the user has changed their account type and if they
                  ///have we need to delete their service profiles (if they exist).
                  if(currentUser.accountType !=
                      accountTypeTextController.text && hasServiceProfiles) {
                    bool deleteProviders = await showYesNoAlert(
                        context: context,
                        title: 'You have changed your account type',
                        body:
                            'We are going to delete your additional service accounts. Do you want to proceed?');

                    if (deleteProviders) {
                      setState(() {
                        showSpinner = true;
                      });

                      await analytics.logEvent(
                          name:
                          'changed_${currentUser.accountType}_to_${accountTypeTextController.text}');

                      for (String id in currentUser.providerProfiles) {
                        User serviceProfile =
                            await fireStoreAPI.getUserById(id);

                        ///Check service profile exists before deleting it
                        if (serviceProfile != null) {
                          await fireStoreAPI.deleteServiceProvider(serviceProvider: serviceProfile);
                        }
                      }
                    }
                  } else {
                    setState(() {
                      showSpinner = true;
                    });
                  }

                  await fireStoreAPI.updateUser(
                      user: User(
                        name: nameController.text,
                        email: emailController.text,
                        accountType: accountTypeTextController.text,
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
                        Text(
                          'Account Type',
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
                                  accountTypeTextController.text,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            itemBuilder: (_) {
                              List<PopupMenuItem<String>> items = [
                              ];
                              for (String accountType
                              in accountTypeList) {
                                items.add(
                                  new PopupMenuItem<String>(
                                      child: Text(accountType),
                                      value: accountType),
                                );
                              }
                              return items;
                            },
                            onSelected: (value) async {
                              if (value != accountTypeTextController.text && hasServiceProfiles) {
                                bool change = await showYesNoAlert(
                                    context: context,
                                    title:
                                    'Are you sure you want to change account type?',
                                    body:
                                    'Doing this will remove any other service accounts associated with this account.');

                                if (change) {
                                  changesMade = true;
                                  accountTypeTextController.text = value;
                                  setState(() {});
                                }
                              } else {
                                changesMade = true;
                                accountTypeTextController.text = value;
                                setState(() {});
                              }
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
                    RoundedButton(
                      buttonTitle: 'Save changes',
                      buttonColor: Color(kGenchiGreen),
                      onPressed: () async {
                        await analytics.logEvent(
                            name: 'hirer_top_save_changes_button_pressed');

                        ///Check if the user has changed their account type and
                        /// if they have we need to delete their service profiles (if they exist).
                        if (currentUser.accountType !=
                            accountTypeTextController.text && hasServiceProfiles) {
                          bool deleteProviders = await showYesNoAlert(
                              context: context,
                              title: 'You have changed your account type',
                              body:
                              'We are going to delete your additional service accounts. Do you want to proceed?');

                          if (deleteProviders) {
                            setState(() {
                              showSpinner = true;
                            });

                            await analytics.logEvent(
                                name:
                                'changed_${currentUser.accountType}_to_${accountTypeTextController.text}');

                            for (String id in currentUser.providerProfiles) {
                              User serviceProfile =
                              await fireStoreAPI.getUserById(id);

                              ///Check provider exists before deleting it
                              if (serviceProfile != null) {
                                await fireStoreAPI.deleteServiceProvider(serviceProvider: serviceProfile);
                              }
                            }
                          }
                        } else {
                          setState(() {
                            showSpinner = true;
                          });
                        }

                        await fireStoreAPI.updateUser(
                            user: User(
                              name: nameController.text,
                              email: emailController.text,
                              accountType: accountTypeTextController.text,
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
                    ),
                    RoundedButton(
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
                          Scaffold.of(context)
                              .showSnackBar(kForgotPasswordSnackbar);

                          setState(() => showSpinner = false);
                        }
                      },
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
