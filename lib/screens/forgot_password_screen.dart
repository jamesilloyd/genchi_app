import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/components/signin_textfield.dart';
import 'package:genchi_app/components/password_error_text.dart';

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

    return Scaffold(
      backgroundColor: Color(kGenchiGreen),
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
              Container(
                height: 50,
              ),
              SignInTextField(
                onChanged: (value) {
                  email = value;
                  //Do something with the user input.
                },
                hintText: "Enter you account email",

              ),
              showErrorField ? PasswordErrorText(errorMessage: errorMessage) : SizedBox(height: 30.0),
              RoundedButton(
                buttonTitle: "Send password reset email",
                buttonColor: Color(kGenchiBlue),
                onPressed: () async {
                  setState(() {
                    showErrorField = false;
                    showSpinner = true;
                  });
                  try {
                    await authProvider.sendResetEmail(email: email);
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
