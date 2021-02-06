import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/signin_textfield.dart';
import 'package:genchi_app/components/snackbars.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UniversityNotListedScreen extends StatefulWidget {
  static const String id = 'uni_not_listed_screen';

  @override
  _UniversityNotListedScreenState createState() =>
      _UniversityNotListedScreenState();
}

class _UniversityNotListedScreenState extends State<UniversityNotListedScreen> {

  TextEditingController universityController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  bool showSpinner = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    universityController.dispose();
    emailController.dispose();
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(kGenchiGreen),
        appBar: BasicAppNavigationBar(
          barTitle: 'University',

        ),
        body: Builder(builder: (BuildContext context) {
          return ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: CircularProgress(),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'What University are you from?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 250,
                        child: TextField(
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            cursorColor: Color(kGenchiOrange),
                            controller: universityController,
                            decoration: kSignInTextFieldDecoration.copyWith(
                                hintText: 'Enter university')),
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: Text(
                          'Email (optional)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 250,
                        child: TextField(
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            cursorColor: Color(kGenchiOrange),
                            controller: emailController,
                            decoration: kSignInTextFieldDecoration.copyWith(
                                hintText: 'Enter email')),
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: Text(
                          'What would you like Genchi for? (optional)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 250,
                        child: TextField(
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            cursorColor: Color(kGenchiOrange),
                            controller: reasonController,
                            decoration: kSignInTextFieldDecoration.copyWith(
                                hintText: 'Enter reason')),
                      ),
                    ],
                  ),
                  RoundedButton(
                    buttonTitle: "Submit",
                    buttonColor: Color(kGenchiBlue),
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());

                      setState(() {
                        showSpinner = true;
                      });

                      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

                      await firebaseAuth.signInAnonymously();
                      firebaseAuth.currentUser;

                      final FirestoreAPIService firestore = FirestoreAPIService();

                      await firestore.addUniveristy(uni: universityController.text,email: emailController.text,reason: reasonController.text);

                      universityController.clear();
                      emailController.clear();
                      reasonController.clear();

                      await firebaseAuth.signOut();
                      setState(() {
                        showSpinner = false;
                      });
                      Scaffold.of(context).showSnackBar(kNewUniversitySnackbar);
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
