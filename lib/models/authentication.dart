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
    try {
      var user = await _firebaseAuth.currentUser();
      await _populateCurrentUser(user); // Populate the user information
      return user != null;
    } catch (e) {
      throw e;
    }
  }

  Future updateCurrentUserData() async {
    var user = await _firebaseAuth.currentUser();
    await _populateCurrentUser(user);
  }

  Future registerWithEmail(
      {@required String email,
      @required String password,
      @required String name}) async {
    try {
      final newUser = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (newUser != null) {
        FirebaseUser user = await _firebaseAuth.currentUser();

        //ToDo: do we want to send verification email?
//      await user.sendEmailVerification();

        //create new user in firestore
        final DateTime timestamp = DateTime.now();
        await _firestoreCRUDModel.addUserByID(
            User(
                id: user.uid,
                email: email,
                name: name,
                timeStamp: timestamp),
            user.uid);
        updateCurrentUserData();
      }
    } catch (e) {
      throw e;
    }
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
