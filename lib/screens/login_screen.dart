import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'home_screen.dart';
import 'package:genchi_app/components/password_error_text.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:provider/provider.dart';
import 'forgot_password_screen.dart';
import 'package:genchi_app/components/signin_textfield.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'reg_sequence_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "login_screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool showSpinner = false;
  bool showErrorField = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    AuthenticationService authProvider =
        Provider.of<AuthenticationService>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(kGenchiGreen),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * .3,
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/LogoAndName.png'),
                  ),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
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
                          password = value;
                        },
                        hintText: "Enter password",
                        isPasswordField: true,
                      ),

                      showErrorField ? PasswordErrorText(errorMessage: errorMessage) : SizedBox(height: 30.0),
                      RoundedButton(
                        buttonColor: Color(kGenchiOrange),
                        buttonTitle: "Log In",
                        onPressed: () async {
                          setState(() {
                            showErrorField = false;
                            showSpinner = true;
                          });
                          try {
                            if (email == null) throw (Exception('Enter email'));

                            await authProvider.loginWithEmail(
                                email: email, password: password);

                            //This populates the current user simultaneously
                            if (await authProvider.isUserLoggedIn() == true) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  HomeScreen.id,
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
                      ),
                      RoundedButton(
                        buttonColor: Color(kGenchiBlue),
                        buttonTitle: "Forgot password",
                        onPressed: () {
                          Navigator.pushNamed(context, ForgotPasswordScreen.id);
                        },
                      ),
                    ],
                  )),
              Container(
                height: MediaQuery.of(context).size.height * .2,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
