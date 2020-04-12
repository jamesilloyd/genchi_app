import 'user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'CRUDModel.dart';
import 'package:genchi_app/locator.dart';


class AuthenticationService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseCRUDModel _firestoreCRUDModel = locator<FirebaseCRUDModel>();

  User _currentUser;
  User get currentUser => _currentUser;

  Future _populateCurrentUser(FirebaseUser user) async {
    if (user != null) {
      _currentUser = await _firestoreCRUDModel.getUserById(user.uid);
    }
  }

  Future<bool> isUserLoggedIn() async {
    var user = await _firebaseAuth.currentUser();
    await _populateCurrentUser(user); // Populate the user information
    return user != null;
  }

  Future updateCurrentUserData() async {
    var user = await _firebaseAuth.currentUser();
    await _populateCurrentUser(user);
  }


//  Future loginWithEmail({
//    @required String email,
//    @required String password,
//  }) async {
//    try {
//      var authResult = await _firebaseAuth.signInWithEmailAndPassword(
//        email: email,
//        password: password,
//      );
//      await _populateCurrentUser(authResult.user); // Populate the user information
//      return authResult.user != null;
//    } catch (e) {
//      return e.message;
//    }
//  }


}