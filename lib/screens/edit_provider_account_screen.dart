import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/drop_down_services.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/add_image_screen.dart';
import 'package:genchi_app/models/services.dart';

import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/provider_service.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';

import 'home_screen.dart';

import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

//TODO: change these to just use text editing controllers

class EditProviderAccountScreen extends StatefulWidget {
  static const id = "edit_provider_account_screen";

  @override
  _EditProviderAccountScreenState createState() =>
      _EditProviderAccountScreenState();
}

class _EditProviderAccountScreenState extends State<EditProviderAccountScreen> {
  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  TextEditingController nameTextController = TextEditingController();
  TextEditingController bioTextController = TextEditingController();
  TextEditingController experienceTextController = TextEditingController();
  TextEditingController priceTextController = TextEditingController();
  TextEditingController serviceTextController = TextEditingController();

  TextEditingController urlDesc1TextController = TextEditingController();
  TextEditingController urlDesc2TextController = TextEditingController();

  TextEditingController url1TextController = TextEditingController();
  TextEditingController url2TextController = TextEditingController();

  //TODO is the following necessary? or can textControllers handle this?
  String name;
  String bio;
  String experience;
  bool showSpinner = false;
  String service;
  String pricing;

  bool changesMade = false;


  Future<bool> _onWillPop() async {
    print('in here');

    if (changesMade) {
      bool discard = await showYesNoAlert(
          context: context, title: 'Are you sure you want to discard changes?');
      if (!discard) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    ProviderUser provider =
        Provider.of<ProviderService>(context, listen: false).currentProvider;
    nameTextController.text = provider.name;
    bioTextController.text = provider.bio;
    experienceTextController.text = provider.experience;
    priceTextController.text = provider.pricing;
    serviceTextController.text = provider.type;

    url1TextController.text = provider.url1['link'];
    urlDesc1TextController.text = provider.url1['desc'];

    url2TextController.text = provider.url2['link'];
    urlDesc2TextController.text = provider.url2['desc'];
  }

  @override
  void dispose() {
    super.dispose();
    nameTextController.dispose();
    bioTextController.dispose();
    experienceTextController.dispose();
    priceTextController.dispose();
    serviceTextController.dispose();
    url1TextController.dispose();
    urlDesc1TextController.dispose();
    url2TextController.dispose();
    urlDesc2TextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    final providerService = Provider.of<ProviderService>(context);
    ProviderUser providerUser = providerService.currentProvider;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Text(
              'Edit Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(kGenchiGreen),
            elevation: 2.0,
            brightness: Brightness.light,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Platform.isIOS
                      ? CupertinoIcons.check_mark_circled
                      : Icons.check_circle_outline,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  await firestoreAPI.updateProvider(
                      provider: ProviderUser(
                          name: name,
                          url1: {
                        'link': url1TextController.text,
                        'desc': urlDesc1TextController.text,
                      },
                          url2: {
                            'link': url2TextController.text,
                            'desc': urlDesc2TextController.text,
                          },
                          type: serviceTextController.text,
                          bio: bio,
                          experience: experience,
                          pricing: pricing),
                      pid: providerUser.pid);

                  await authProvider.updateCurrentUserData();
                  await providerService.updateCurrentProvider(providerUser.pid);

                  setState(() {
                    changesMade = false;
                    showSpinner = false;
                  });

                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: CircularProgress(),
            child: ListView(
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
                Center(
                  child: Text(
                    'Display Picture',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Color(kGenchiBlue),
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0))),
                      builder: (context) => SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: AddImageScreen(isUser: false)),
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      DisplayPicture(
                        imageUrl: providerUser.displayPictureURL,
                        height: 0.25,
                        border: true,
                      ),
                      Positioned(
                        right: (MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.height * 0.25) /
                            2,
                        top: MediaQuery.of(context).size.height * 0.2,
                        child: new Container(
                          height: 30,
                          width: 30,
                          padding: EdgeInsets.all(2),
                          decoration: new BoxDecoration(
                              color: Color(kGenchiCream),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: Color(0xff585858), width: 2)),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Center(
                                child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Color(0xff585858),
                            )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                EditAccountField(
                  field: "Provider Profile Name",
                  textController: nameTextController,
                  hintText: "Either your name or your brand's name",
                  onChanged: (value) {
                    name = value;
                    changesMade = true;
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 30.0,
                    ),
                    Text(
                      'Service',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Color(kGenchiBlue),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    SizedBox(
                      height: 50.0,
                      child: Container(
                        color: Color(kGenchiCream),
                        child: DropdownButton<String>(
                            value: initialDropDownValue(currentType: serviceTextController.text),
                            items: dropDownServiceItems(),
                            onChanged: (value) {
                              setState(() {
                                changesMade = true;
                                serviceTextController.text = value;
                              });
                            },
                          ),
                      ),
                    ),
                  ],
                ),
                EditAccountField(
                  field: 'About me',
                  textController: bioTextController,
                  hintText: 'What your service/offering is',
                  onChanged: (value) {
                    bio = value;
                    changesMade = true;
                  },
                ),
                EditAccountField(
                  field: 'Experience',
                  textController: experienceTextController,
                  hintText: 'E.g. how you developed your skills',
                  onChanged: (value) {
                    experience = value;
                    changesMade = true;
                  },
                ),
//                EditAccountField(
//                  field: "Price",
//                  onChanged: (value) {
//                    changesMade = true;
//                    pricing = value;
//                  },
//                  textController: priceTextController,
//                  hintText: "E.g. for experience, £10 per job etc.",
//                ),

                //TODO COME BACK TO THIS, ADDED TEMPORARY SOLUTION FOR DEMO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 30.0,
                    ),
                    Text(
                      "Website Links",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Color(kGenchiBlue),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            onChanged: (value) {
                              changesMade = true;
                            },
                            controller: urlDesc1TextController,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: "URL 1 Description "),
                            cursorColor: Color(kGenchiOrange),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            textCapitalization: TextCapitalization.none,
                            maxLines: null,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            onChanged: (value) {
                              changesMade = true;
                            },
                            controller: url1TextController,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'URL 1 "https://www..."'),
                            cursorColor: Color(kGenchiOrange),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            onChanged: (value) {
                              changesMade = true;
                            },
                            controller: urlDesc2TextController,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: "URL 2 Description"),
                            cursorColor: Color(kGenchiOrange),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            textCapitalization: TextCapitalization.none,
                            maxLines: null,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                            onChanged: (value) {
                              changesMade = true;
                            },
                            controller: url2TextController,
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'URL 2 "https://www..."'),
                            cursorColor: Color(kGenchiOrange),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                //TODO Implement the following fields
                EditAccountField(
                  hintText: 'Coming soon',
                  field: "Portfolio Pictures",
                  isEditable: false,
                  onChanged: (value) {},
                  textController: TextEditingController(),
                ),
                EditAccountField(
                  hintText: 'Coming soon',
                  field: "Tags",
                  isEditable: false,
                  onChanged: (value) {},
                  textController: TextEditingController(),
                ),

                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 30,
                ),
                RoundedButton(
                  buttonTitle: "Delete provider account",
                  buttonColor: Color(kGenchiBlue),
                  elevation: false,
                  onPressed: () async {
                    ///Update the provider before deleting

                    await providerService
                        .updateCurrentProvider(providerUser.pid);

                    ///Get most up to data provider
                    providerUser =
                        Provider.of<ProviderService>(context, listen: false)
                            .currentProvider;

                    Platform.isIOS
                        ? showAlertIOS(
                            context: context,
                            actionFunction: () async {
                              setState(() => showSpinner = true);

                              await firestoreAPI.deleteProvider(
                                  provider: providerUser);
                              await authProvider.updateCurrentUserData();
                              changesMade = false;
                              setState(() => showSpinner = false);

                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  HomeScreen.id,
                                  (Route<dynamic> route) => false,
                                  arguments:
                                      HomeScreenArguments(startingIndex: 3));
                            },
                            alertMessage: 'Delete Account')
                        : showAlertAndroid(
                            context: context,
                            actionFunction: () async {
                              setState(() => showSpinner = true);

                              await firestoreAPI.deleteProvider(
                                  provider: providerUser);
                              await authProvider.updateCurrentUserData();
                              changesMade = false;
                              setState(() => showSpinner = false);

                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  HomeScreen.id,
                                  (Route<dynamic> route) => false,
                                  arguments:
                                      HomeScreenArguments(startingIndex: 3));
                            },
                            alertMessage: "Delete Account");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
