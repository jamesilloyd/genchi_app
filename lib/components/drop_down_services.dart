import 'package:flutter/material.dart';
import 'package:genchi_app/models/services.dart';

List<DropdownMenuItem> dropDownServiceItems() {
  List<DropdownMenuItem<String>> dropdownItems = [];
  for (Map serviceType in servicesListMap) {
    var newItem = DropdownMenuItem(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10,0,0,0),
        child: Text(
          serviceType['name'],
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      value: serviceType['name'].toString(),
    );
    dropdownItems.add(newItem);
  }
  return dropdownItems;
}
