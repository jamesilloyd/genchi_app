import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/snackbars.dart';

import 'package:genchi_app/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/services/authentication_service.dart';

import 'package:genchi_app/components/signin_textfield.dart';
import 'package:genchi_app/components/password_error_text.dart';
import 'package:genchi_app/components/platform_alerts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String id = 'forgot_password_screen';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email;
  bool showSpinner = false;
  bool showErrorField = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Color(kGenchiGreen),
        appBar: BasicAppNavigationBar(
          barTitle: "Forgot Password",
        ),
        body: Builder(builder: (BuildContext context) {
          return ModalProgressHUD(
            progressIndicator: CircularProgress(),
            inAsyncCall: showSpinner,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 50,
                  ),
                  SignInTextField(
                    field: 'Email',
                    onChanged: (value) {
                      email = value;
                      //Do something with the user input.
                    },
                    hintText: "Enter you account email",
                  ),
                  showErrorField
                      ? PasswordErrorText(errorMessage: errorMessage)
                      : SizedBox(height: 30.0),
                  RoundedButton(
                    buttonTitle: "Send password reset email",
                    buttonColor: Color(kGenchiBlue),
                    onPressed: () async {
                      Platform.isIOS
                          ? showAlertIOS(
                              context: context,
                              actionFunction: () async {
                                setState(() {
                                  showErrorField = false;
                                  showSpinner = true;
                                });
                                try {
                                  if (email != null) {
                                    await authProvider.sendResetEmail(email: email);
                                    ScaffoldMessenger.of(context).showSnackBar(kForgotPasswordSnackbar);
                                  } else {
                                    throw ("Enter an email address");
                                  }
                                } catch (e) {
                                  print(e);
                                  showErrorField = true;
                                  errorMessage = e.message;
                                }
                                setState(() {
                                  showSpinner = false;
                                });
                                Navigator.of(context).pop();
                              },
                              alertMessage: "Reset password")
                          : showAlertAndroid(
                              context: context,
                              actionFunction: () async {
                                setState(() {
                                  showErrorField = false;
                                  showSpinner = true;
                                });
                                try {
                                  if (email != null) {
                                    await authProvider.sendResetEmail(
                                        email: email);
                                    ScaffoldMessenger.of(context).showSnackBar(kForgotPasswordSnackbar);
                                  } else {
                                    throw ("Enter an email address");
                                  }
                                } catch (e) {
                                  print(e);
                                  showErrorField = true;
                                  errorMessage = e.message;
                                }
                                setState(() {
                                  showSpinner = false;
                                });
                                Navigator.of(context).pop();
                              },
                              alertMessage: "Reset password");
                    },
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
