import 'package:flutter/material.dart';

import 'package:genchi_app/services/firestore_api_service.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/models/user.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreAPIService _firestoreCRUDModel = FirestoreAPIService();

  User _currentUser;
  User get currentUser => _currentUser;

  Future _populateCurrentUser(FirebaseUser user) async {
    print("populating current user");
    if (user != null) {
      if(debugMode) print('Authentication service _populateCurrentUser: user ${user.uid}');
      _currentUser = await _firestoreCRUDModel.getUserById(user.uid);
      notifyListeners();
      //TODO: how to handle error here ???
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      print("isUserLoggedIn");
      var user = await _firebaseAuth.currentUser();
      if(user != null) {
        await _populateCurrentUser(user); // Populate the
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e;
    }
  }


  Future updateCurrentUserData() async {
    var user = await _firebaseAuth.currentUser();
    await _populateCurrentUser(user);
  }

  Future updateCurrentUserName({@required String name}) async {
    var user = await _firebaseAuth.currentUser();

    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await user.updateProfile(userUpdateInfo);
  }

  Future registerWithEmail(
      {@required String email,
      @required String password,
      @required String name}) async {
    try {
      AuthResult authResult = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);


      if (authResult != null) {
        print("register successful");
        UserUpdateInfo userUpdateInfo = UserUpdateInfo();
        userUpdateInfo.displayName = name;
        FirebaseUser user = await _firebaseAuth.currentUser();
        ///add the users name in firebase auth
        await user.updateProfile(userUpdateInfo);
        ///create new user in firestore database
        final DateTime timestamp = DateTime.now();
        await _firestoreCRUDModel.addUserByID(
            User(id: user.uid, email: email, name: name, timeStamp: timestamp, admin: false));
        await updateCurrentUserData();
      }
    } catch (e) {
      throw e;
    }
  }

  Future loginWithEmail({
    @required String email,
    @required String password,
  }) async {
    try {
      final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult != null) {
        print("login successful");
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> sendResetEmail({@required email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signUserOut() async {
    await _firebaseAuth.signOut();
  }
}
