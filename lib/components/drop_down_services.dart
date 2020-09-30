import 'package:flutter/material.dart';
import 'package:genchi_app/models/user.dart';

List<DropdownMenuItem> dropDownServiceItems() {
  List<DropdownMenuItem<String>> dropdownItems = [];
  for (Service serviceType in servicesList) {
    var newItem = DropdownMenuItem(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10,0,0,0),
        child: Text(
          serviceType.databaseValue.toUpperCase(),
        ),
      ),
      value: serviceType.databaseValue,
    );
    dropdownItems.add(newItem);
  }
  return dropdownItems;
}

List<DropdownMenuItem> dropDownAccountTypeItems() {
  List<DropdownMenuItem<String>> dropdownItems = [];
  for (String accountType in GenchiUser().accessibleAccountTypes) {
    var newItem = DropdownMenuItem(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10,0,0,0),
        child: Text(
          accountType.toUpperCase(),
        ),
      ),
      value: accountType,
    );
    dropdownItems.add(newItem);
  }
  return dropdownItems;
}

initialDropDownValue({String currentType}) {
  if (currentType != '') {
    ///Editing an existing task
    for (Service service in servicesList) {
      if (currentType == service.databaseValue) {
        return currentType;
      }
    }
  } else {
    return 'Other';
  }
}