import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/customer_needs_screen.dart';
import 'package:genchi_app/screens/university_not_listed_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:genchi_app/components/password_error_text.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/components/signin_textfield.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class RegistrationScreen extends StatefulWidget {
  static const String id = "registration_screen";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  String name;

  bool showSpinner = false;
  bool showErrorField = false;
  String errorMessage = "";
  bool agreed = false;
  String accountType;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  TextEditingController universityTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    universityTypeController.text = 'Select University';
  }

  @override
  void dispose() {
    super.dispose();
    universityTypeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationService authProvider =
        Provider.of<AuthenticationService>(context);

    AccountService accountService = Provider.of<AccountService>(context);
    final RegistrationScreenArguments args =
        ModalRoute.of(context).settings.arguments;

    accountType = args.accountType;
    print(accountType);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Color(kGenchiGreen),
        body: ModalProgressHUD(
          progressIndicator: CircularProgress(),
          inAsyncCall: showSpinner,
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * .07,
                  child: Align(
                    alignment: Alignment.bottomLeft,
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
                    //TODO: only show both fields if it's a individual account
                    SignInTextField(
                      onChanged: (value) {
                        name = value;
                      },
                      field: accountType == 'Individual'? 'Full Name':'$accountType Name',
                      hintText: "Enter name",
                      isNameField: true,
                      autocorrect: true,
                    ),

                    SizedBox(
                      height: 10.0,
                    ),
                    if (accountType != 'Company')
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'University',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          PopupMenuButton(
                              elevation: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(32.0))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                  child: Text(
                                    universityTypeController.text,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: universityTypeController.text ==
                                              'Select University'
                                          ? Colors.black45
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder: (_) {
                                List<PopupMenuItem<String>> items = [
                                  new PopupMenuItem<String>(
                                      child: Text(
                                        'Select University',
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                      value: 'Select University')
                                ];
                                for (String accountType
                                    in GenchiUser().accessibleUniversities) {
                                  items.add(
                                    new PopupMenuItem<String>(
                                        child: Text(accountType),
                                        value: accountType),
                                  );
                                }
                                return items;
                              },
                              onSelected: (value) {
                                universityTypeController.text = value;
                                setState(() {});
                              }),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),

                    SignInTextField(
                      field: 'Email',
                      autocorrect: false,
                      onChanged: (value) {
                        email = value;
                      },
                      hintText: "Enter email",
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SignInTextField(
                      field: 'Password',
                      autocorrect: false,
                      onChanged: (value) {
                        password = value;
                      },
                      hintText: "Enter password",
                      isPasswordField: true,
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: agreed,
                            onChanged: (value) {
                              setState(() {
                                agreed = value;
                              });
                            }),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'I have read and accept the ',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Colors.blue),
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {
                                    launch(GenchiPPURL);
                                  },
                              ),
                              TextSpan(
                                text: '.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    showErrorField
                        ? PasswordErrorText(errorMessage: errorMessage)
                        : SizedBox(height: 20.0),
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
                            throw (Exception('Enter account details'));

                          if (accountType != 'Company' &&
                              universityTypeController.text ==
                                  'Select University')
                            throw (Exception('Enter account details'));
                          if (agreed == false)
                            throw (Exception(
                                'Please accept the Privacy Policy'));

                          await authProvider.registerWithEmail(
                              email: email.replaceAll(' ', ''),
                              password: password,
                              uni: universityTypeController.text,
                              type: accountType,
                              name: name,);

                          await FirebaseAnalytics()
                              .logSignUp(signUpMethod: 'email');

                          ///This populates the current user simultaneously
                          if (await authProvider.isUserLoggedIn() == true) {
                            ///Registration complete, so now handing over to the accountService to handle provider
                            await accountService.updateCurrentAccount(
                                id: authProvider.currentUser.id);

                            ///Quickly ask for permission to take notification on iOS
                            ///TODO: move this

                            if (Platform.isIOS) {
                              NotificationSettings settings =
                                  await _fcm.requestPermission(
                                alert: true,
                                announcement: false,
                                badge: true,
                                carPlay: false,
                                criticalAlert: false,
                                provisional: false,
                                sound: true,
                              );

                              print(
                                  'User granted permission: ${settings.authorizationStatus}');
                            }

                            /// Get the current user
                            GenchiUser currentUser =
                                Provider.of<AuthenticationService>(context,
                                        listen: false)
                                    .currentUser;

                            /// Get the token for this device
                            String fcmToken = await _fcm.getToken();

                            print('fcmToken is $fcmToken');

                            /// Save it to Firestore
                            if (fcmToken != null) {
                              firestoreAPI.addFCMToken(
                                  token: fcmToken, user: currentUser);
                            }

                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                CustomerNeedsScreen.id,
                                (Route<dynamic> route) => false,
                                arguments: PreferencesScreenArguments(
                                    isFromRegistration: true));
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
                    if (accountType != 'Company')
                      RoundedButton(
                          buttonColor: Color(kGenchiLightOrange),
                          buttonTitle: "University not listed?",
                          fontColor: Colors.black,
                          onPressed: () {
                            Navigator.pushNamed(
                                context, UniversityNotListedScreen.id);
                          })
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
