import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;
FirebaseUser loggedInUser;

//ToDo: centralise all authentication methods, need to find a way to store user data

Future<Map<String,String>> getCurrentUser() async {
  Map<String,String> userDetails = {};
  try {
    final user = await _auth.currentUser();
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.email);
      print(loggedInUser.displayName);
      userDetails["userName"]= loggedInUser.displayName;
      userDetails["userEmail"] = loggedInUser.email;
    }
  } catch (e) {
    print(e);
  }
  return userDetails;
}