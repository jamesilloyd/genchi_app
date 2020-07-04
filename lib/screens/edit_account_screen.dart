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

class EditAccountScreen extends StatefulWidget {
  static const id = "edit_account_screen";
  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {

  bool changesMade = false;
  final FirestoreAPIService fireStoreAPI = FirestoreAPIService();
  bool showSpinner = false;
  String name;
  String email;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<bool> _onWillPop() async {

    if(changesMade){
      bool discard = await showYesNoAlert(context:context, title: 'Are you sure you want to discard changes?');
      if(!discard) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    User user = Provider.of<AuthenticationService>(context, listen: false).currentUser;
    nameController.text = user.name;
    emailController.text = user.email;
  }
  
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: (){
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
                  Platform.isIOS ? CupertinoIcons.check_mark_circled : Icons.check_circle_outline,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  print("$name $email");
                  await fireStoreAPI.updateUser(user:
                  User(name: name, email: email),
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
                  padding: EdgeInsets.all(20.0),
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Display Picture',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Color(kGenchiBlue),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 5.0
                    ),
                    GestureDetector(
                      onTap: (){
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
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Container(
                                      height: MediaQuery.of(context).size.height *
                                          0.75,
                                      child: AddImageScreen(isUser: true)),
                                ),
                            ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          DisplayPicture(imageUrl: currentUser.displayPictureURL, height: 0.25,border: true,isEdit: true,),
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
                        name = value;
                      },
                      textController: nameController,
                    ),
                    EditAccountField(
                      field: "Email",
                      isEditable: false,
                      onChanged: (value) {
                        changesMade = true;
                        email = value;
                      },
                      textController: emailController,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Divider(
                      height: 10,
                    ),
                    RoundedButton(
                      buttonColor: Color(kGenchiBlue),
                      buttonTitle: "Change Password",
                      onPressed: () async {
                        Platform.isIOS
                            ? showAlertIOS(
                                context: context,
                                actionFunction: () async {
                                  setState(() => showSpinner = true);
                                  await authProvider.sendResetEmail(email: currentUser.email);
                                  Scaffold.of(context).showSnackBar(kForgotPasswordSnackbar);
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
