import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/edit_account_text_field.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';

import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/services.dart';

import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditProviderAccountScreen extends StatefulWidget {
  static const id = "edit_provider_account_screen";
  @override
  _EditProviderAccountScreenState createState() =>
      _EditProviderAccountScreenState();
}

class _EditProviderAccountScreenState extends State<EditProviderAccountScreen> {
  String name;
  String email;
  bool showSpinner = false;
  String selectedService = servicesList[0];

  DropdownButton<String> androidDropdownButton() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String service in servicesList) {
      var newItem = DropdownMenuItem(
        child: Text(
          service,
        ),
        value: service,
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
      value: selectedService,
      items: dropdownItems,
      onChanged: (value) {
        setState(() {
          selectedService = value;
//          getData(selectedCurrency);
        });
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> pickerItems = [];
    for (String service in servicesList) {
      var newItem = Text(service);
      pickerItems.add(newItem);
    }

    return CupertinoPicker(
      backgroundColor: Color(kGenchiCream),
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedService = pickerItems[selectedIndex].data;
//          getData(selectedCurrency);
        });
      },
      children: pickerItems,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            ),
            EditAccountField(
              field: "Provider Profile Name",
              initialValue: '',
              onChanged: (value) {
                //Update name field
                name = value;
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
                    child: Platform.isIOS ? iOSPicker() : androidDropdownButton(),
                  ),
                ),
              ],
            ),
            EditAccountField(
              field: 'Description',
              initialValue: '',
              isEditable: false,
              onChanged: (value) {
                //Update name field
                email = value;
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
