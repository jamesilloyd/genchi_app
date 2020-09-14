import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'home_screen.dart';
import 'package:genchi_app/components/password_error_text.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:provider/provider.dart';
import 'forgot_password_screen.dart';
import 'package:genchi_app/components/signin_textfield.dart';
import 'package:genchi_app/components/circular_progress.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "login_screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool showSpinner = false;
  bool showErrorField = false;
  String errorMessage = "";


  @override
  Widget build(BuildContext context) {
    AuthenticationService authProvider =
        Provider.of<AuthenticationService>(context);
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Color(kGenchiGreen),
        body: ModalProgressHUD(
          progressIndicator: CircularProgress(),
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * .1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Color(kGenchiBlue),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SignInTextField(
                          field: 'Email',
                          onChanged: (value) {
                            email = value;
                          },
                          hintText: "Enter email",
                          isNameField: false,
                        ),

                        SizedBox(
                          height: 10.0,
                        ),
                        SignInTextField(
                          field: 'Password',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
