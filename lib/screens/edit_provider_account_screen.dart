import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/add_image_screen.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/account_service.dart';

import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

import 'package:genchi_app/models/screen_arguments.dart';

import 'home_screen.dart';

import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditProviderAccountScreen extends StatefulWidget {
  static const id = "edit_provider_account_screen";

  @override
  _EditProviderAccountScreenState createState() =>
      _EditProviderAccountScreenState();
}

class _EditProviderAccountScreenState extends State<EditProviderAccountScreen> {
  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  TextEditingController nameTextController = TextEditingController();
  TextEditingController bioTextController = TextEditingController();
  TextEditingController serviceTextController = TextEditingController();
  TextEditingController subCategoryTextController = TextEditingController();

  bool showSpinner = false;
  bool changesMade = false;

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
    GenchiUser currentAccount =
        Provider.of<AccountService>(context, listen: false).currentAccount;
    nameTextController.text = currentAccount.name;
    bioTextController.text = currentAccount.bio;
    serviceTextController.text = currentAccount.category;
    subCategoryTextController.text = currentAccount.subcategory;
  }

  @override
  void dispose() {
    super.dispose();
    nameTextController.dispose();
    bioTextController.dispose();
    serviceTextController.dispose();
    subCategoryTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    final accountService = Provider.of<AccountService>(context);
    GenchiUser serviceProvider = accountService.currentAccount;

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
              'Edit Details',
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
                  analytics.logEvent(
                      name: 'provider_top_save_changes_button_pressed');
                  setState(() {
                    showSpinner = true;
                  });

                  await firestoreAPI.updateUser(
                      user: GenchiUser(
                        name: nameTextController.text,
                        category: serviceTextController.text,
                        bio: bioTextController.text,
                        subcategory: subCategoryTextController.text,
                        fcmTokens: authProvider.currentUser.fcmTokens,
                      ),
                      uid: serviceProvider.id);

                  await authProvider.updateCurrentUserData();
                  await accountService.updateCurrentAccount(
                      id: serviceProvider.id);

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
                Center(
                  child: Text(
                    'Display Picture',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
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
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: AddImageScreen(isUser: false),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      LargeDisplayPicture(
                        imageUrl: serviceProvider.displayPictureURL,
                        height: 0.25,
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
                  field: "Provider Profile Name",
                  textController: nameTextController,
                  hintText: "Either your name or your brand's name",
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              serviceTextController.text,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        itemBuilder: (_) {
                          List<PopupMenuItem<String>> items = [];
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
                            serviceTextController.text = value;
                          });
                        }),
                  ],
                ),
                EditAccountField(
                  field: 'Subcategory',
                  hintText:
                      'What type of ${serviceTextController.text == "" ? serviceProvider.accountType.toLowerCase() : serviceTextController.text.toLowerCase()} skills do you offer?',
                  onChanged: (value) {
                    changesMade = true;
                  },
                  textController: subCategoryTextController,
                ),
                EditAccountField(
                  field: 'About me',
                  textController: bioTextController,
                  hintText: 'What your service/offering is',
                  onChanged: (value) {
                    changesMade = true;
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 30,
                ),
                Center(
                  child: RoundedButton(
                    buttonTitle: 'Save changes',
                    buttonColor: Color(kGenchiGreen),
                    onPressed: () async {
                      analytics.logEvent(
                          name: 'provider_bottom_save_changes_button_pressed');
                      setState(() {
                        showSpinner = true;
                      });

                      await firestoreAPI.updateUser(
                          user: GenchiUser(
                            name: nameTextController.text,
                            category: serviceTextController.text,
                            bio: bioTextController.text,
                            subcategory: subCategoryTextController.text,
                            fcmTokens: authProvider.currentUser.fcmTokens,
                          ),
                          uid: serviceProvider.id);

                      await authProvider.updateCurrentUserData();
                      await accountService.updateCurrentAccount(
                          id: serviceProvider.id);

                      setState(() {
                        changesMade = false;
                        showSpinner = false;
                      });

                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Center(
                  child: RoundedButton(
                    buttonTitle: "Delete provider account",
                    buttonColor: Color(kGenchiBlue),
                    elevation: false,
                    onPressed: () async {
                      ///Update the provider before deleting

                      await accountService.updateCurrentAccount(
                          id: serviceProvider.id);

                      ///Get most up to data provider
                      serviceProvider =
                          Provider.of<AccountService>(context, listen: false)
                              .currentAccount;

                      bool delete = await showYesNoAlert(
                          context: context, title: "Delete Service Account?");

                      if (delete) {
                        setState(() {
                          showSpinner = true;
                        });

                        ///Log event in firebase
                        await analytics.logEvent(
                            name: 'provider_account_deleted');

                        await firestoreAPI.deleteServiceProvider(
                            serviceProvider: serviceProvider);
                        await authProvider.updateCurrentUserData();
                        changesMade = false;
                        setState(() => showSpinner = false);

                        Navigator.pushNamedAndRemoveUntil(context,
                            HomeScreen.id, (Route<dynamic> route) => false,
                            arguments: HomeScreenArguments(startingIndex: 3));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
