import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/components/password_error_text.dart';
import 'reg_sequence_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/models/user.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password1;
  String password2;
  String name;
  bool showSpinner = false;
  bool showErrorField = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    FirebaseCRUDModel profileProvider = Provider.of<FirebaseCRUDModel>(context);
    AuthenticationService authProvider =
        Provider.of<AuthenticationService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/Logo_Clear.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
//                textCapitalization: TextCapitalization.words,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    name = value;
                  },
                  decoration:
                      kTextFieldDecoration.copyWith(hintText: "Enter name")),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration:
                      kTextFieldDecoration.copyWith(hintText: "Enter email")),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password1 = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter password")),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password2 = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: "Repeat password")),
              SizedBox(height: 16.0),
              showErrorField
                  ? PasswordErrorText(errorMessage: errorMessage)
                  : SizedBox(height: 13.0),
              RoundedButton(
                buttonColor: Colors.blueAccent,
                buttonTitle: "Register",
                onPressed: () async {
                  setState(() {
                    showErrorField = false;
                    showSpinner = true;
                  });
                  try {

                    if(name == null || email == null) throw(Exception('Enter name and email'));


                    if(password1 != password2) throw(Exception("Passwords do not match"));

                    await authProvider.registerWithEmail(
                        email: email, password: password1, name: name);

                    //This populates the current user simultaneously
                    if (await authProvider.isUserLoggedIn() == true) {
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          RegSequenceScreen.id,
                          (Route<dynamic> route) => false);
                    }
                  } catch (e) {
                    print(e);
                    showErrorField = true;
                    errorMessage = e.message;
                  }

                  setState(() {
                    showSpinner = false;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
