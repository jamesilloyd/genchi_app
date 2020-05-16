import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'provider.dart';
import 'chat.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    return  _chatCollectionRef.document(chatId).collection('messages').orderBy('time', descending: true).snapshots();
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
    return ProviderUser.fromMap(doc.data);
  }

  Future<Map<Chat, ProviderUser>> getUserChatsAndProviders({List<dynamic> chatIds}) async {

//    _chatCollectionRef

    Map<Chat, ProviderUser> chatAndProviders = {};
    List<Chat> chats = [];
    for (String chatId in chatIds) {
      Chat chat = await getChatById(chatId);
      chats.add(chat);
    }

    chats.sort((a,b) => b.time.compareTo(a.time));
    for (Chat chat in chats) {
      ProviderUser provider = await getProviderById(chat.pid);
      chatAndProviders[chat] = provider;
    }
    return chatAndProviders;

  }

  Future<Map<ProviderUser, Map<Chat, User>>> getUserProviderChatsAndUsers({List<dynamic> usersPids}) async {


    Map<ProviderUser, Map<Chat, User>> userProviderChatsAndUsers = {};


    for (String pid in usersPids) {

      List<Chat> chats = [];
      Map<Chat, User> chatsAndUsers = {};

      ProviderUser provider = await getProviderById(pid);

      if(provider.chats.isNotEmpty) {
        for (String chatId in provider.chats) {
          Chat chat = await getChatById(chatId);
          chats.add(chat);
        }

        chats.sort((a,b) => b.time.compareTo(a.time));

        for (Chat chat in chats) {
          User chatUser = await getUserById(chat.uid);
          chatsAndUsers[chat] = chatUser;
        }
        userProviderChatsAndUsers[provider] = chatsAndUsers;
      }

    }

    return userProviderChatsAndUsers;
  }



  Future removeUser(String uid) async {
    await _usersCollectionRef.document(uid).delete();
    return;
  }

  Future removeProvider(String pid) async {
    await _providersCollectionRef.document(pid).delete();
    return;
  }


  Future updateUser({User user, String uid}) async {
    await _usersCollectionRef.document(uid).setData(user.toJson(),merge: true);
    return;
  }

  Future updateProvider({ProviderUser provider, String pid}) async {
    await _providersCollectionRef.document(pid).setData(provider.toJson(),merge: true);
    return;
  }

  Future updateChat({Chat chat}) async {
    await _chatCollectionRef.document(chat.chatid).setData(chat.toJson(),merge: true);
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

  Future addMessageToChat({String chatId, ChatMessage chatMessage, bool providerIsSender}) async {

    Chat chat = Chat(lastMessage: chatMessage.text, time: chatMessage.time);

    providerIsSender ? chat.userHasUnreadMessage = true : chat.providerHasUnreadMessage = true;

    await _chatCollectionRef.document(chatId).setData(chat.toJson(), merge: true);
    var result = await _chatCollectionRef.document(chatId).collection('messages').add(chatMessage.toJson());
  }

  Future<DocumentReference> addProvider(ProviderUser provider,String uid) async {

    DocumentReference result = await _providersCollectionRef.add(provider.toJson()).then((docRef) async {
    await updateProvider(provider: ProviderUser(pid: docRef.documentID),pid: docRef.documentID,);
    await _usersCollectionRef.document(uid).setData({'providerProfiles': FieldValue.arrayUnion([docRef.documentID])},merge: true);
    return docRef;
    });

    return result;
  }

  Future<DocumentReference> addNewChat({String uid, String pid, String providersUid}) async {

    Chat chat = Chat(uid: uid, pid: pid, providerdsUid: providersUid);

    DocumentReference result = await _chatCollectionRef.add(chat.toJson()).then( (docRef) async {
      await updateChat(chat: Chat(chatid: docRef.documentID));
      await _usersCollectionRef.document(uid).setData({'chats': FieldValue.arrayUnion([docRef.documentID])},merge: true);
      await _providersCollectionRef.document(pid).setData({'chats': FieldValue.arrayUnion([docRef.documentID])},merge: true);
      return docRef;
    });

    return result;
  }

  Future<void> deleteProvider({ProviderUser provider}) async {
    for(Chat chat in provider.chats) {
      await updateChat(chat: Chat(chatid: chat.chatid, isDeleted : true, lastMessage: 'Provider No Longer Exists'));
    }
    await _providersCollectionRef.document(provider.pid).delete();
    await _usersCollectionRef.document(provider.uid).setData({'providerProfiles': FieldValue.arrayRemove([provider.pid])},merge: true);
  }

  Future<void> deleteChat({Chat chat}) async {
    await _chatCollectionRef.document(chat.chatid).delete();
    await _providersCollectionRef.document(chat.pid).setData({'chats': FieldValue.arrayRemove([chat.chatid])},merge: true);
    await _providersCollectionRef.document(chat.uid).setData({'chats': FieldValue.arrayRemove([chat.chatid])},merge: true);
  }

  Future<void> deleteUserDisplayPicture({User user}) async {
    await FirebaseStorage.instance.ref().child(user.displayPictureFileName).delete();
    await _usersCollectionRef.document(user.id).setData({'displayPictureFileName': FieldValue.delete(),'displayPictureURL':FieldValue.delete()},merge: true);
  }

  Future<void> deleteProviderDisplayPicture({ProviderUser provider}) async {
    await FirebaseStorage.instance.ref().child(provider.displayPictureFileName).delete();
    await _providersCollectionRef.document(provider.pid).setData({'displayPictureFileName': FieldValue.delete(),'displayPictureURL':FieldValue.delete()},merge: true);
  }


}

