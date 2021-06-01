import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/account_service.dart';

import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/user.dart';

import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/add_image_screen.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class EditAccountScreen extends StatefulWidget {
  static const id = "edit_account_screen";

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  bool changesMade = false;
  final FirestoreAPIService fireStoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  bool showSpinner = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
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
    bioController.text = user.bio;
    categoryController.text = user.category;
    universityTextController.text = user.university;
    subCategoryController.text = user.subcategory;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
    categoryController.dispose();
    subCategoryController.dispose();
    universityTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    GenchiUser currentUser = authProvider.currentUser;
    final accountService = Provider.of<AccountService>(context);
    print('Edit account screen activated');
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
                  setState(() {
                    showSpinner = true;
                  });

                  await fireStoreAPI.updateUser(
                      user: GenchiUser(
                          name: nameController.text,
                          bio: bioController.text,
                          category: categoryController.text,
                          subcategory: subCategoryController.text,
                          university: universityTextController.text),
                      uid: currentUser.id);

                  ///If name has changed update in the auth section
                  if (nameController.text != currentUser.name) {
                    await authProvider.updateCurrentUserName(
                        name: nameController.text);
                  }

                  await accountService.updateCurrentAccount(id: currentUser.id);
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
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                child: AddImageScreen(),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          LargeDisplayPicture(
                            imageUrl: currentUser.displayPictureURL,
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
                        changesMade = true;
                      },
                      textController: nameController,
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
                    //TODO: this needs updating
                    // if (currentUser.accountType != 'Individual')
                    //   Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: <Widget>[
                    //       Container(
                    //         height: 30.0,
                    //       ),
                    //       Text(
                    //         'Category',
                    //         style: TextStyle(
                    //           fontSize: 20.0,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //       SizedBox(height: 5.0),
                    //       PopupMenuButton(
                    //           elevation: 1,
                    //           child: Container(
                    //             decoration: BoxDecoration(
                    //                 color: Colors.white,
                    //                 borderRadius:
                    //                     BorderRadius.all(Radius.circular(32.0)),
                    //                 border: Border.all(color: Colors.black)),
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(
                    //                   vertical: 12.0, horizontal: 20.0),
                    //               child: Text(
                    //                 categoryController.text,
                    //                 style: TextStyle(
                    //                   fontSize: 18,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           itemBuilder: (_) {
                    //             List<PopupMenuItem<String>> items = [];
                    //             for (GroupType groupType in groupsList) {
                    //               var newItem = new PopupMenuItem(
                    //                 child: Text(
                    //                   groupType.databaseValue,
                    //                 ),
                    //                 value: groupType.databaseValue,
                    //               );
                    //               items.add(newItem);
                    //             }
                    //             return items;
                    //           },
                    //           onSelected: (value) async {
                    //             setState(() {
                    //               changesMade = true;
                    //               categoryController.text = value;
                    //             });
                    //           }),
                    //     ],
                    //   ),
                    // if (currentUser.accountType != 'Individual')
                    //   EditAccountField(
                    //     field: 'Subcategory',
                    //     hintText:
                    //         'What type of ${categoryController.text == "" ? currentUser.accountType.toLowerCase() : categoryController.text.toLowerCase()} are you?',
                    //     onChanged: (value) {
                    //       changesMade = true;
                    //     },
                    //     textController: subCategoryController,
                    //   ),
                    EditAccountField(
                      field: "About",
                      onChanged: (value) {
                        //Update name
                        changesMade = true;
                      },
                      textController: bioController,
                      hintText: currentUser.accountType == 'Individual'
                          ? 'College, Interests, Societies, etc.'
                          : 'Describe what you do you.',
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Divider(
                      height: 10,
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
