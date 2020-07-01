import 'package:flutter/material.dart';
import 'firestore_api_service.dart';

import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/constants.dart';


class ProviderService extends ChangeNotifier {

  final FirestoreAPIService _firestoreCRUDModel = FirestoreAPIService();

  ProviderUser _currentProvider;
  ProviderUser get currentProvider => _currentProvider;

  Future updateCurrentProvider(pid) async {

    if(debugMode) print("updateCurrentProvider called: populating provider");
    if (pid != null) {
      ProviderUser provider = await _firestoreCRUDModel.getProviderById(pid);
      if(provider!=null) {
        _currentProvider = provider;
        notifyListeners();
      }
    }

    //TODO how to handle null provider
  }


}
