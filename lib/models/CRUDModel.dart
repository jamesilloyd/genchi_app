import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'package:genchi_app/models/authentication.dart';
import 'provider.dart';
import 'chat.dart';

//This class is specifically for Profile CRUD

//TODO: FIRST THING AFTER MVP RELEASE use the .where function to easily filter providers/chats etc.
class FirestoreCRUDModel {


  CollectionReference _usersCollectionRef = Firestore.instance.collection('users');
  CollectionReference _providersCollectionRef = Firestore.instance.collection('providers');
  CollectionReference _chatCollectionRef = Firestore.instance.collection('chats');

  List<User> users;
  List<ProviderUser> providers;


  Future<List<User>> fetchUsers() async {
    var result = await _usersCollectionRef.getDocuments();
    users = result.documents
        .map((doc) => User.fromMap(doc.data))
        .toList();
    return users;
  }

  Future<List<ProviderUser>> fetchProviders() async {
    var result = await _providersCollectionRef.getDocuments();
    providers = result.documents.map((doc) => ProviderUser.fromMap(doc.data)).toList();
    return providers;
  }

  Stream<QuerySnapshot> fetchChatStream(String chatId) {
    return  _chatCollectionRef.document(chatId).collection('messages').snapshots();
  }


  Stream<QuerySnapshot> fetchUsersAsStream() {
    return _usersCollectionRef.snapshots();
  }

  Stream<QuerySnapshot> fetchProvidersAsStream() {
    return _providersCollectionRef.snapshots();
  }



  Future<Chat> getChatById(String chatId) async {
    var doc = await _chatCollectionRef.document(chatId).get();
    return Chat.fromMap(doc.data);
  }


  Future<User> getUserById(String uid) async {
    var doc = await _usersCollectionRef.document(uid).get();
    return User.fromMap(doc.data);
  }

  Future<ProviderUser> getProviderById(String pid) async {
    var doc = await _providersCollectionRef.document(pid).get();
//    var doc1 = await _providersCollectionRef.document(pid).snapshots();
    return ProviderUser.fromMap(doc.data);
  }



  Future removeUser(String uid) async {
    await _usersCollectionRef.document(uid).delete();
    return;
  }

  Future removeProvider(String pid) async {
    await _providersCollectionRef.document(pid).delete();
    return;
  }


  Future updateUser(User user, String uid) async {
    await _usersCollectionRef.document(uid).setData(user.toJson(),merge: true);
    return;
  }

  Future updateProvider(ProviderUser provider, String pid) async {
    await _providersCollectionRef.document(pid).setData(provider.toJson(),merge: true);
    return;
  }

  Future updateChat(Chat chat, String chatId) async {
    await _chatCollectionRef.document(chatId).setData(chat.toJson(),merge: true);
  }


  Future addUserByID(User user) async {
    var result = await _usersCollectionRef.document(user.id).setData(user.toJson());
    return;
  }

  Future addProviderByID(ProviderUser provider) async {
    var result = await _providersCollectionRef.document(provider.pid).setData(provider.toJson());
    return;
  }


  Future addUser(User user) async {
    var result = await _usersCollectionRef.add(user.toJson());
    return result;
  }

  Future addMessageToChat(String chatId, ChatMessage chatMessage) async {

    var result = await _chatCollectionRef.document(chatId).collection('messages').add(chatMessage.toJson());
  }

  Future<DocumentReference> addProvider(ProviderUser provider,String uid) async {

    DocumentReference result = await _providersCollectionRef.add(provider.toJson()).then((docRef) async {
    await updateProvider(ProviderUser(pid: docRef.documentID),docRef.documentID,);
    await _usersCollectionRef.document(uid).setData({'providerProfiles': FieldValue.arrayUnion([docRef.documentID])},merge: true);
    return docRef;
    });

    return result;
  }

  Future<DocumentReference> addNewChat({String uid, String pid, String providersUid}) async {

    Chat chat = Chat(uid: uid, pid: pid, providerdsUid: providersUid);

    DocumentReference result = await _chatCollectionRef.add(chat.toJson()).then( (docRef) async {
      await updateChat(Chat(chatid: docRef.documentID),docRef.documentID);
      await _usersCollectionRef.document(uid).setData({'chats': FieldValue.arrayUnion([docRef.documentID])},merge: true);
      await _providersCollectionRef.document(pid).setData({'chats': FieldValue.arrayUnion([docRef.documentID])},merge: true);
      return docRef;
    });

    return result;
  }

  Future<void> deleteProvider({String pid, String uid}) async {
    await _providersCollectionRef.document(pid).delete();
    await _usersCollectionRef.document(uid).setData({'providerProfiles': FieldValue.arrayRemove([pid])},merge: true);
}


}

