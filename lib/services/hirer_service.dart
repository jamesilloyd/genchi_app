import 'package:flutter/material.dart';
import 'package:genchi_app/models/user.dart';
import 'firestore_api_service.dart';

import 'package:genchi_app/constants.dart';


class HirerService extends ChangeNotifier {

  final FirestoreAPIService _firestoreCRUDModel = FirestoreAPIService();

  User _currentHirer;
  User get currentHirer => _currentHirer;

  Future updateCurrentHirer({String id}) async {

    if(debugMode) print("updateCurrentHirer called: populating hirer on $id");
    if (id != null) {
      User hirer = await _firestoreCRUDModel.getUserById(id);
      if(hirer!=null) {
        _currentHirer = hirer;
        notifyListeners();
      }
    }

    //TODO how to handle null hirer
  }


}
