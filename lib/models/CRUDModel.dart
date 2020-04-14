import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genchi_app/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'package:genchi_app/models/authentication.dart';

//This class is specifically for Profile CRUD
class FirebaseCRUDModel extends ChangeNotifier {


  CollectionReference _usersCollectionRef = Firestore.instance.collection('users');

  List<User> users;

  //ToDo: allow the ability to pass in a parameter for the collection TYPE to simplifiy/refactor
  Future<List<User>> fetchUsers() async {
    var result = await _usersCollectionRef.getDocuments();
    users = result.documents
        .map((doc) => User.fromMap(doc.data))
        .toList();
    return users;
  }

  Stream<QuerySnapshot> fetchUsersAsStream() {
    return _usersCollectionRef.snapshots();
  }

  Future<User> getUserById(String id) async {
    var doc = await _usersCollectionRef.document(id).get();
    return User.fromMap(doc.data);
  }


  Future removeUser(String id) async {
    await _usersCollectionRef.document(id).delete();
    return;
  }

  Future updateUser(User user, String id) async {
    await _usersCollectionRef.document(id).setData(user.toJson(),merge: true);
    return;
  }

  Future addUserByID(User user) async {
    var result = await _usersCollectionRef.document(user.id).setData(user.toJson());
    return;
  }

  Future addUser(User user) async {
    var result = await _usersCollectionRef.add(user.toJson());
    return;
  }

}

