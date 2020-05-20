import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/components/password_error_text.dart';
import 'reg_sequence_screen.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/components/signin_textfield.dart';

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
    AuthenticationService authProvider =
        Provider.of<AuthenticationService>(context);

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(kGenchiGreen),
        body: ModalProgressHUD(
          progressIndicator: CircularProgress(),
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * .2,
                  child: Center(
                    child: Hero(
                      tag: 'logo',
                      child: Container(
                        child: Image.asset('images/LogoAndName.png'),
                      ),
                    ),
                  ),
                ),
                Container(
//                  height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SignInTextField(
                          onChanged: (value) {
                            name = value;
                          },
                          hintText: "Enter name",
                          isNameField: true,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        SignInTextField(
                          onChanged: (value) {
                            email = value;
                          },
                          hintText: "Enter email",
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        SignInTextField(
                          onChanged: (value) {
                            password1 = value;
                          },
                          hintText: "Enter password",
                          isPasswordField: true,
                        ),

                        SizedBox(
                          height: 10.0,
                        ),
                        SignInTextField(
                          onChanged: (value) {
                            password2 = value;
                          },
                          hintText: "Repeat password",
                          isPasswordField: true,
                        ),
                        showErrorField
                            ? PasswordErrorText(errorMessage: errorMessage)
                            : SizedBox(height: 30.0),
                        RoundedButton(
                          buttonColor: Color(kGenchiBlue),
                          buttonTitle: "Register",
                          onPressed: () async {
                            setState(() {
                              showErrorField = false;
                              showSpinner = true;
                            });
                            try {
                              if (name == null || email == null)
                                throw (Exception('Enter name and email'));

                              if (password1 != password2)
                                throw (Exception("Passwords do not match"));

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
                    )),
                Container(
                  height: MediaQuery.of(context).size.height * .2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
