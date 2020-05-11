import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/user.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/edit_account_text_field.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';


class EditAccountScreen extends StatefulWidget {
  static const id = "edit_account_screen";
  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {

  final FirestoreCRUDModel fireStoreAPI = FirestoreCRUDModel();
  bool showSpinner = false;
  String name;
  String email;

  TextEditingController nameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Edit Details"),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
              EditAccountField(
                field: "Display Picture",
                initialValue: 'Coming Soon',
                isEditable: false,
                onChanged: (value) {
                },
                textController: TextEditingController(),
              ),
              EditAccountField(
                field: "Name",
                initialValue: authProvider.currentUser.name ?? '',
                onChanged: (value) {
                  //Update name field
                  name = value;
                },
                changedParameter: name,
                textController: nameController,
              ),
              EditAccountField(
                field: "Email",
                initialValue: authProvider.currentUser.email ?? '',
                isEditable: false,
                onChanged: (value) {
                  //Update name field
                  email = value;
                },
                changedParameter: email,
                textController: TextEditingController(),
              ),
              SizedBox(
                height: 10.0,
              ),
              Divider(
                height: 10,
              ),
              RoundedButton(
                buttonTitle: "Save Details",
                buttonColor: Color(kGenchiOrange),
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  print("$name $email");
                  await fireStoreAPI.updateUser(
                      User(name: name, email: email),
                      authProvider.currentUser.id);
                  await authProvider.updateCurrentUserData();

                  setState(() {
                    showSpinner = false;
                  });
                  Navigator.pop(context);
                },
              ),
              RoundedButton(
                buttonColor: Color(kGenchiBlue),
                buttonTitle: "Change Password",
                onPressed: () {
                  Platform.isIOS
                      ? showAlertIOS(context, () {
                          authProvider.sendResetEmail(
                              email: authProvider.currentUser.email);
                          Navigator.of(context).pop();
                        }, "Reset password")
                      : showAlertAndroid(context, () {
                          authProvider.sendResetEmail(
                              email: authProvider.currentUser.email);
                          Navigator.of(context).pop();
                        }, "Reset password");
                },
              ),
            ],
          ),
      ),
    );
  }
}
