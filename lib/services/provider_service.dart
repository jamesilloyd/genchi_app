import 'package:flutter/material.dart';
import 'firestore_api_service.dart';

import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/constants.dart';


class ProviderService extends ChangeNotifier {

  final FirestoreAPIService _firestoreCRUDModel = FirestoreAPIService();

  //ToDo to be updated (1)
  ProviderUser _currentProvider;
  ProviderUser get currentProvider => _currentProvider;

  //ToDo to be updated (1)
  Future updateCurrentProvider(pid) async {

    if(debugMode) print("updateCurrentProvider called: populating provider");
    if (pid != null) {
      _currentProvider = await _firestoreCRUDModel.getProviderById(pid);
      notifyListeners();
    }
  }


}
