import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/components/password_error_text.dart';
import 'reg_sequence_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //make it a private final
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  String name;
  bool showSpinner = false;
  bool showErrorField = false;
  String errorMessage = "";
  final DateTime timestamp = DateTime.now();


  final CollectionReference usersRef = Firestore.instance.collection('users');

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
                buttonColor: Colors.blueAccent,
                buttonTitle: "Register",
                onPressed: () async {
                  setState(() {
                    showErrorField = false;
                    showSpinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);

                    if (newUser != null) {
                      FirebaseUser user = await _auth.currentUser();

                      //Update auth name
                      UserUpdateInfo updateInfo = UserUpdateInfo();
                      updateInfo.displayName = name;
                      user.updateProfile(updateInfo);

                      await user.sendEmailVerification();

                      //create new user in firestore
                      //ToDo: need to be using the "toJSON" from profile class here!
                      usersRef.document(user.uid).setData({
                        'id': user.uid,
                        'photoUrl': '',
                        'email': user.email,
                        'displayName': name,
                        'bio': '',
                        'timestamp': timestamp,
                      });

                      Navigator.pushNamedAndRemoveUntil(
                          context, RegSequenceScreen.id, (Route<dynamic> route) => false);
                    }
                  } catch (e) {
                    showErrorField = true;
                    errorMessage = e.message;
                    print(e.code);
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
