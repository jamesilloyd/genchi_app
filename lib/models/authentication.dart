import 'user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'CRUDModel.dart';
import 'provider.dart';


//ToDo: (1) Once everything is currently working, just leave as is, however once complete try and implement FilledStacks provider and firebase examples
//https://github.com/FilledStacks/flutter-tutorials

class AuthenticationService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreCRUDModel _firestoreCRUDModel = FirestoreCRUDModel();

  //ToDo to be updated (1)
  User _currentUser;
  User get currentUser => _currentUser;

  //ToDo to be updated (1)
  Future _populateCurrentUser(FirebaseUser user) async {
    print("populating current user");
    if (user != null) {
      _currentUser = await _firestoreCRUDModel.getUserById(user.uid);
      notifyListeners();
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      print("isUserLoggedIn");
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
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (authResult != null) {
        print("register successful");
        FirebaseUser user = await _firebaseAuth.currentUser();

        //ToDo: do we want to send verification email?
//      await user.sendEmailVerification();

        //create new user in firestore
        final DateTime timestamp = DateTime.now();
        await _firestoreCRUDModel.addUserByID(
            User(id: user.uid, email: email, name: name, timeStamp: timestamp));
        updateCurrentUserData();
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

//ToDo: may be able to integrate this into CRUDModel
class ProviderService extends ChangeNotifier {

  final FirestoreCRUDModel _firestoreCRUDModel = FirestoreCRUDModel();

  //ToDo to be updated (1)
  ProviderUser _currentProvider;
  ProviderUser get currentProvider => _currentProvider;

  //ToDo to be updated (1)
  Future updateCurrentProvider(pid) async {

    print("populating provider");
    if (pid != null) {
      _currentProvider = await _firestoreCRUDModel.getProviderById(pid);
      notifyListeners();
    }
  }


}
