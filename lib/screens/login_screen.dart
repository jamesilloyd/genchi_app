import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'home_screen.dart';
import 'package:genchi_app/components/password_error_text.dart';

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
              //Prevent hero image overflowing
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
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                  //Do something with the user input.
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: "Enter email"),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter password")),
              SizedBox(height: 16.0),
              showErrorField
                  ? PasswordErrorText(errorMessage: errorMessage)
                  : SizedBox(height: 13.0),
              RoundedButton(
                buttonColor: Colors.lightBlueAccent,
                buttonTitle: "Log In",
                onPressed: () async {
                  setState(() {
                    showErrorField = false;
                    showSpinner = true;
                  });
                  try {
                    final currentUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (currentUser != null) {
                      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id,
                          (Route<dynamic> route) => false);
                    }
                  } catch (e) {
                    print(e.code);
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
