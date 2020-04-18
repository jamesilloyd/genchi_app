import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/constants.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/models/user.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/components/platform_alerts.dart';

class EditAccountScreen extends StatefulWidget {
  static const id = "edit_account_screen";
  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {

//  final TextEditingController _controller = new TextEditingController();

  String name;
  String email;
  String bio;

  @override
  Widget build(BuildContext context) {
    final firestoreProvider = Provider.of<FirestoreCRUDModel>(context);
    final authProvider = Provider.of<AuthenticationService>(context);

    return Scaffold(
      //ToDo: add functionality that questions users to continue if changes have been made (e.g. u sure u wanna discard changes?)
      appBar: MyAppNavigationBar(barTitle: "Edit Account"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            EditAccountField(
              field: "Name",
              initialValue: authProvider.currentUser.name ?? '',
              onChanged: (value) {
                //Update name field
                name = value;
              },
            ),
            EditAccountField(
              field: "Bio",
              initialValue: authProvider.currentUser.bio ?? '',
              onChanged: (value) {
                //Update name field
                bio = value;
              },
            ),
            EditAccountField(
              field: "Email",
              initialValue: authProvider.currentUser.email ?? '',
              isEditable: false,
              onChanged: (value) {
                //Update name field
                email = value;
              },
            ),
            RoundedButton(
              buttonTitle: "Save Details",
              buttonColor: Colors.grey,
              onPressed: () async {
                print("$name $email $bio");
                await firestoreProvider.updateUser(
                    User(name: name, email: email, bio: bio),
                    authProvider.currentUser.id);
                await authProvider.updateCurrentUserData();
              },
            ),
            RoundedButton(
              buttonColor: Colors.greenAccent,
              buttonTitle: "Change password",
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

class EditAccountField extends StatelessWidget {
  const EditAccountField(
      {@required this.field,
      this.initialValue,
      @required this.onChanged,
      this.isEditable = true});

  final String field;
  final String initialValue;
  final Function onChanged;
  final bool isEditable;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 40.0,
        ),
        Text(
          field,
        ),
        TextField(
          style: TextStyle(
            color: isEditable ? Colors.black : Colors.grey,
          ),
          textAlign: TextAlign.left,
          onChanged: onChanged,
          readOnly: isEditable ? false : true,
          controller: TextEditingController()..text = initialValue,
          decoration: kTextFieldDecoration.copyWith(),
        ),
      ],
    );
  }
}
