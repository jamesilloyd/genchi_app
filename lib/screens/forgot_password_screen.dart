import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'dart:io' show Platform;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class ForgotPasswordScreen extends StatefulWidget {
  static const String id = 'forgot_password_screen';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: MyAppNavigationBar(
        barTitle: "Forgot Password",
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(height: 50,),
              TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter your account email")),
              RoundedButton(
                buttonTitle: "Send password reset email",
                buttonColor: Colors.grey,
                onPressed: () async {
                  setState((){
                    showSpinner = true;
                  });
                  try {
                    await authProvider.sendResetEmail(email: email);
                  } catch (e) {
                    //ToDo: handle the error to give feedback to user
                    print(e);
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
