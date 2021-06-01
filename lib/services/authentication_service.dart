import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info/package_info.dart';

class AuthenticationService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreAPIService _firestoreCRUDModel = FirestoreAPIService();

  GenchiUser _currentUser;

  GenchiUser get currentUser => _currentUser;

  Future _populateCurrentUser(User user) async {
    print("populating current user");
    if (user != null) {
      if (debugMode)
        print('Authentication service _populateCurrentUser: user ${user.uid}');
      // _currentUser = await _firestoreCRUDModel.getUserById('S0pOGZzspV8eKxoml39w');

      _currentUser = await _firestoreCRUDModel.getUserById(user.uid);
      notifyListeners();
      //TODO: how to handle error here ???
    }
  }


  //TODO: change the name of this
  Future<bool> isUserLoggedIn() async {

    try {
      print("isUserLoggedIn");
      var user = _firebaseAuth.currentUser;
      if (user != null) {
        await _populateCurrentUser(user); // Populate the user
        ///Update version number data
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        GenchiUser thisUser = currentUser;
        thisUser.versionNumber = packageInfo.version;
        thisUser.sessionCount ++;
        await _firestoreCRUDModel.updateUser(user: thisUser,uid: thisUser.id);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e;
    }
  }

  Future updateCurrentUserData() async {
    var user = _firebaseAuth.currentUser;
    await _populateCurrentUser(user);
  }

  Future updateCurrentUserName({@required String name}) async {
    var user = _firebaseAuth.currentUser;

    await user.updateProfile(displayName: name);
  }

  Future registerWithEmail(
      {@required String email,
      @required String password,
      @required String type,
        @required String uni,
      @required String name}) async {
    try {
      UserCredential authResult = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (authResult != null) {
        print("register successful");
        User user = _firebaseAuth.currentUser;

        ///add the users name in firebase auth
        await user.updateProfile(displayName: name);

        ///create new user in firestore database
        await _firestoreCRUDModel.addUserByID(GenchiUser(
            id: user.uid,
            email: email,
            name: name,
            university: uni,
            timeStamp: Timestamp.now(),
            admin: false,
            accountType: type));
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
