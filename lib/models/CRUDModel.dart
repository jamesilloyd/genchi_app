import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genchi_app/locator.dart';
import 'firebaseAPI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

//This class is specifically for Profile CRUD
class CRUDModel extends ChangeNotifier {

  Api _api = locator<Api>();

  List<User> products;


  Future<List<User>> fetchProducts() async {
    var result = await _api.getDataCollection();
    products = result.documents
        .map((doc) => User.fromMap(doc.data, doc.documentID))
        .toList();
    return products;
  }

  Stream<QuerySnapshot> fetchProductsAsStream() {
    return _api.streamDataCollection();
  }

  Future<User> getUserById(String id) async {
    var doc = await _api.getDocumentById(id);
    return  User.fromMap(doc.data, doc.documentID) ;
  }


  Future removeProduct(String id) async{
    await _api.removeDocument(id) ;
    return ;
  }
  Future updateUser(User data, String id) async{
    await _api.updateDocument(data.toJson(), id) ;
    return ;
  }

  Future addUser(User user, String id) async{
    var result  = await _api.addDocumentById(user.toJson(), id) ;
    return ;
  }


}