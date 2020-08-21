import 'package:flutter/material.dart';
import 'package:genchi_app/models/user.dart';
import 'firestore_api_service.dart';

import 'package:genchi_app/constants.dart';


class AccountService extends ChangeNotifier {

  final FirestoreAPIService _firestoreCRUDModel = FirestoreAPIService();

  User _currentAccount;
  User get currentAccount => _currentAccount;

  Future updateCurrentAccount({String id}) async {

    if(debugMode) print("updateCurrentAccount called: populating account with $id");
    if (id != null) {
      User account = await _firestoreCRUDModel.getUserById(id);
      if(account!=null) {
        _currentAccount = account;
        notifyListeners();
      }
    }

    //TODO how to handle null hirer
  }


}
