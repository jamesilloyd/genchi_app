import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

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
import 'package:url_launcher/url_launcher.dart';

class EditAccountScreen extends StatefulWidget {
  static const id = "edit_account_screen";

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  bool changesMade = false;
  final FirestoreAPIService fireStoreAPI = FirestoreAPIService();
  bool showSpinner = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController collegeController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController bioController = TextEditingController();


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
    collegeController.text = user.college;
    subjectController.text = user.subject;
    bioController.text = user.bio;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    collegeController.dispose();
    subjectController.dispose();
    bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;
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
                  setState(() {
                    showSpinner = true;
                  });

                  await fireStoreAPI.updateUser(
                      user: User(
                          name: nameController.text,
                          email: emailController.text,
                          college: collegeController.text,
                          bio: bioController.text,
                          subject: subjectController.text),
                      uid: currentUser.id);
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
                                  child: AddImageScreen(isUser: true)),
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          DisplayPicture(
                            imageUrl: currentUser.displayPictureURL,
                            height: 0.25,
                            border: true,
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
                    EditAccountField(
                      field: "Email",
                      isEditable: false,
                      onChanged: (value) {
                        changesMade = true;
                      },
                      textController: emailController,
                    ),
                    EditAccountField(
                      field: "College",
                      onChanged: (value) {
                        //Update name
                        changesMade = true;
                      },
                      textController: collegeController,
                      hintText: 'Which college are you in?',
                    ),
                    EditAccountField(
                      field: "Subject",
                      onChanged: (value) {
                        //Update name
                        changesMade = true;
                      },
                      textController: subjectController,
                      hintText: 'What do you study?',
                    ),
                    EditAccountField(
                      field: "About Me",
                      onChanged: (value) {
                        //Update name
                        changesMade = true;
                      },
                      textController: bioController,
                      hintText: 'Interests, Activities, Societies, etc.',
                    ),
                    //TODO COME BACK TO THIS, ADDED TEMPORARY SOLUTION FOR DEMO
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 30.0,
                        ),
                        Text(
                          "Website Links",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: Color(kGenchiBlue),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                decoration: kTextFieldDecoration.copyWith(
                                    hintText: "URL 1 Description "),
                                cursorColor: Color(kGenchiOrange),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                textCapitalization: TextCapitalization.none,
                                maxLines: null,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.left,
                                onChanged: (value) {
                                  changesMade = true;
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                    hintText: 'URL 1 "https://www..."'),
                                cursorColor: Color(kGenchiOrange),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                decoration: kTextFieldDecoration.copyWith(
                                    hintText: "URL 2 Description"),
                                cursorColor: Color(kGenchiOrange),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                textCapitalization: TextCapitalization.none,
                                maxLines: null,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.left,
                                onChanged: (value) {
                                  changesMade = true;
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                    hintText: 'URL 2 "https://www..."'),
                                cursorColor: Color(kGenchiOrange),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                      onPressed: ()async {
                        setState(() {
                          showSpinner = true;
                        });

                        await fireStoreAPI.updateUser(
                            user: User(
                                name: nameController.text,
                                email: emailController.text,
                                college: collegeController.text,
                                bio: bioController.text,
                                subject: subjectController.text),
                            uid: currentUser.id);
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
                        Platform.isIOS
                            ? showAlertIOS(
                                context: context,
                                actionFunction: () async {
                                  setState(() => showSpinner = true);
                                  await authProvider.sendResetEmail(
                                      email: currentUser.email);
                                  Scaffold.of(context)
                                      .showSnackBar(kForgotPasswordSnackbar);
                                  setState(() => showSpinner = false);
                                  Navigator.of(context).pop();
                                },
                                alertMessage: "Reset password")
                            : showAlertAndroid(
                                context: context,
                                actionFunction: () async {
                                  await authProvider.sendResetEmail(
                                      email: currentUser.email);
                                  Scaffold.of(context)
                                      .showSnackBar(kForgotPasswordSnackbar);
                                  Navigator.of(context).pop();
                                },
                                alertMessage: "Reset password");
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
