import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genchi_app/locator.dart';
import 'firebaseAPI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';

class CRUDModel extends ChangeNotifier {

  Api _api = locator<Api>();

  List<Profile> products;


  Future<List<Profile>> fetchProducts() async {
    var result = await _api.getDataCollection();
    products = result.documents
        .map((doc) => Profile.fromMap(doc.data, doc.documentID))
        .toList();
    return products;
  }

  Stream<QuerySnapshot> fetchProductsAsStream() {
    return _api.streamDataCollection();
  }

  Future<Profile> getProductById(String id) async {
    var doc = await _api.getDocumentById(id);
    return  Profile.fromMap(doc.data, doc.documentID) ;
  }


  Future removeProduct(String id) async{
    await _api.removeDocument(id) ;
    return ;
  }
  Future updateProduct(Profile data, String id) async{
    await _api.updateDocument(data.toJson(), id) ;
    return ;
  }

  Future addProduct(Profile data) async{
    var result  = await _api.addDocument(data.toJson()) ;

    return ;

  }


}