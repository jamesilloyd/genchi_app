import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/components/platform_alerts.dart';

import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';

import 'home_screen.dart';

import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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

  String name;
  String bio;
  bool showSpinner = false;
  String service;

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
          print(name);
          print(bio);
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    final EditProviderAccountScreenArguments args =
        ModalRoute.of(context).settings.arguments ??
            EditProviderAccountScreenArguments();
    bool fromRegistration = args.fromRegistration;

    final providerService = Provider.of<ProviderService>(context);
    ProviderUser providerUser = providerService.currentProvider;

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Edit Details"),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
            EditAccountField(
              field: "Display Picture",
              initialValue: 'Coming Soon',
              isEditable: false,
              onChanged: (value) {},
              textController: TextEditingController(),
            ),
            EditAccountField(
              field: "Provider Profile Name",
              initialValue: providerUser.name ?? '',
              textController: nameTextController,
              onChanged: (value) {
                //Update name field
                name = value;
              },
              changedParameter: name,
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
              field: 'Description',
              initialValue: providerUser.bio ?? '',
              textController: bioTextController,
              changedParameter: bio,
              onChanged: (value) {
                //Update name field
                bio = value;
              },
            ),
            SizedBox(
              height: 10.0,
            ),
            Divider(
              height: 10,
            ),
            RoundedButton(
              buttonTitle: "Save Details",
              buttonColor: Color(kGenchiOrange),
              onPressed: () async {
                print('$name $service $bio ${providerUser.pid}');

                await firestoreAPI.updateProvider(
                    ProviderUser(name: name, type: service, bio: bio),
                    providerUser.pid);
                await authProvider.updateCurrentUserData();
                await providerService.updateCurrentProvider(providerUser.pid);

                fromRegistration
                    ? Navigator.pushNamedAndRemoveUntil(
                        context, HomeScreen.id, (Route<dynamic> route) => false,
                        arguments: HomeScreenArguments(startingIndex: 2))
                    : Navigator.of(context).pop();
              },
            ),
            RoundedButton(
              buttonTitle: fromRegistration
                  ? "Cancel (you can make one later)"
                  : "Delete provider account",
              buttonColor: Color(kGenchiBlue),
              onPressed: () async {
                Platform.isIOS
                    ? showAlertIOS(context, () async {
                        await firestoreAPI.deleteProvider(
                            pid: providerUser.pid,
                            uid: authProvider.currentUser.id);
                        await authProvider.updateCurrentUserData();

                        Navigator.pushNamedAndRemoveUntil(context,
                            HomeScreen.id, (Route<dynamic> route) => false);
                      }, 'Delete Account')
                    : showAlertAndroid(context, () async {
                        await firestoreAPI.deleteProvider(
                            pid: providerUser.pid,
                            uid: authProvider.currentUser.id);
                        await authProvider.updateCurrentUserData();
                        Navigator.pushNamedAndRemoveUntil(context,
                            HomeScreen.id, (Route<dynamic> route) => false);
                      }, "Delete Account");
              },
            ),
          ],
        ),
      ),
    );
  }
}
