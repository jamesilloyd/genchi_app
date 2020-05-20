import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/add_image_screen.dart';
import 'package:genchi_app/components/discard_changes_alert.dart';

import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';

import 'home_screen.dart';

import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';



//TODO - DELETE PROVIDER ACCOUNT, CURSOR RESETTING, CHANGES MADE BOOL AND REMOVE KEYBOARD
class EditProviderAccountScreen extends StatefulWidget {
  static const id = "edit_provider_account_screen";
  @override
  _EditProviderAccountScreenState createState() =>
      _EditProviderAccountScreenState();
}

class _EditProviderAccountScreenState extends State<EditProviderAccountScreen> {

  FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();
  TextEditingController nameTextController = TextEditingController();
  TextEditingController bioTextController = TextEditingController();
  TextEditingController experienceTextController = TextEditingController();
  TextEditingController priceTextController = TextEditingController();

  String name;
  String bio;
  String experience;
  bool showSpinner = false;
  String service;
  String pricing;

  bool changesMade = false;

  DropdownButton<String> androidDropdownButton(currentService) {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (Map serviceType in servicesListMap) {
      var newItem = DropdownMenuItem(
        child: Text(
          serviceType['name'],
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        value: serviceType['name'],
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
      value: service ?? (currentService == '' ? 'Other' : currentService),
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          service = value;
        });
      },
    );
  }

  CupertinoPicker iOSPicker(currentService) {
    List<Text> pickerItems = [];
    for (Map serviceType in servicesListMap) {
      var newItem = Text(serviceType['name']);
      pickerItems.add(newItem);
    }

    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: servicesListMap.indexWhere((service) => service['name'] == currentService),
      ),
      backgroundColor: Color(kGenchiCream),
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        service = pickerItems[selectedIndex].data;
      },
      children: pickerItems,
    );
  }

  Future<bool> _onWillPop() async {

    print('in here');

    if(changesMade){
      bool discard = await showDiscardChangesAlert(context:context);
      if(!discard) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    ProviderUser provider = Provider.of<ProviderService>(context, listen: false).currentProvider;
    nameTextController.text = provider.name;
    bioTextController.text = provider.bio;
    experienceTextController.text = provider.experience;
    priceTextController.text = provider.pricing;

  }

  @override
  void dispose() {
    super.dispose();
    nameTextController.dispose();
    bioTextController.dispose();
    experienceTextController.dispose();
    priceTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    final EditProviderAccountScreenArguments args =
        ModalRoute.of(context).settings.arguments ??
            EditProviderAccountScreenArguments();
    bool fromRegistration = args.fromRegistration;

    final providerService = Provider.of<ProviderService>(context);
    ProviderUser providerUser = providerService.currentProvider;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Color(kGenchiBlue),
            ),
            title: Text(
              'Edit Details',
              style: TextStyle(
                color: Color(kGenchiBlue),
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(kGenchiCream),
            elevation: 2.0,
            brightness: Brightness.light,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                    Platform.isIOS ? CupertinoIcons.check_mark_circled : Icons.check_circle_outline,
                    size: 30,
                    color: Color(kGenchiBlue),
                ),
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  await firestoreAPI.updateProvider(provider:
                  ProviderUser(name: name, type: service, bio: bio, experience: experience, pricing: pricing),
                      pid: providerUser.pid);
                  await authProvider.updateCurrentUserData();
                  await providerService.updateCurrentProvider(providerUser.pid);

                  setState(() {
                    changesMade = false;
                    showSpinner = false;
                  });

                  fromRegistration
                      ? Navigator.pushNamedAndRemoveUntil(
                      context, HomeScreen.id, (Route<dynamic> route) => false,
                      arguments: HomeScreenArguments(startingIndex: 2))
                      : Navigator.of(context).pop();
                },
              )
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: CircularProgress(),
            child: ListView(
              padding: EdgeInsets.all(20.0),
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
                SizedBox(
                    height: 5.0
                ),
                GestureDetector(
                  onTap: (){
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
                              bottom: MediaQuery.of(context)
                                  .viewInsets
                                  .bottom),
                          child: Container(
                              height: MediaQuery.of(context).size.height *
                                  0.75,
                              child: AddImageScreen(isUser: false)),
                        ),
                      ),
                    );
                  },
                  child: DisplayPicture(imageUrl: providerUser.displayPictureURL, height: 0.25),
                ),
                EditAccountField(
                  field: "Provider Profile Name",
                  textController: nameTextController,
                  hintText: "Either your name or your brand's name",
                  onChanged: (value) {
                    name = value;
                    changesMade = true;
                    print(name);
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
                      height: Platform.isIOS ? 100.0 : 50.0,
                      child: Container(
                        color: Color(kGenchiCream),
                        child: Platform.isIOS
                            ? iOSPicker(providerUser.type)
                            : androidDropdownButton(providerUser.type),
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

                  },
                ),
                EditAccountField(
                  field: "Price",
                  onChanged: (value) {
                    changesMade = true;
                    pricing = value;

                    },
                  textController: priceTextController,
                  hintText: "E.g. for experience, £10 per job etc.",
                ),
                //TODO Implement the following fields
                EditAccountField(
                  field: "Portfolio Pictures",
                  isEditable: false,
                  onChanged: (value) {},
                  textController: TextEditingController(),
                ),
                EditAccountField(
                  field: "Tags",
                  isEditable: false,
                  onChanged: (value) {},
                  textController: TextEditingController(),
                ),

                //TODO: fb as well? probably want to centralise on here if possible, but may be useful for societies?
                EditAccountField(
                  field: "Website Links",
                  isEditable: false,
                  onChanged: (value) {},
                  textController: TextEditingController(),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 10,
                ),
                RoundedButton(
                  buttonTitle: fromRegistration
                      ? "Cancel (you can make one later)"
                      : "Delete provider account",
                  buttonColor: Color(kGenchiBlue),
                  onPressed: () async {
                    Platform.isIOS
                        ? showAlertIOS(context: context, actionFunction: () async {
                          setState(() => showSpinner = true);

                            await firestoreAPI.deleteProvider(provider: providerUser);
                            await authProvider.updateCurrentUserData();
                            changesMade = false;
                            setState(() => showSpinner = false);

                            Navigator.pushNamedAndRemoveUntil(context,
                                HomeScreen.id, (Route<dynamic> route) => false);
                          }, alertMessage: 'Delete Account')
                        : showAlertAndroid(context: context, actionFunction: () async {
                            setState(() => showSpinner = true);

                            await firestoreAPI.deleteProvider(provider : providerUser);
                            await authProvider.updateCurrentUserData();
                            changesMade = false;
                            setState(() => showSpinner = false);

                            Navigator.pushNamedAndRemoveUntil(context,
                                HomeScreen.id, (Route<dynamic> route) => false);
                          },alertMessage: "Delete Account");
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
