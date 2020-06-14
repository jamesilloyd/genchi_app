import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/provider.dart';
import '../models/chat.dart';
import 'package:genchi_app/models/task.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:genchi_app/constants.dart';


//TODO: FIRST THING AFTER MVP RELEASE use the .where function to easily filter providers/chats etc.
class FirestoreAPIService {

  CollectionReference _usersCollectionRef = Firestore.instance.collection('users');
  CollectionReference _providersCollectionRef = Firestore.instance.collection('providers');
  CollectionReference _chatCollectionRef = Firestore.instance.collection('chats');
  CollectionReference _taskCollectionRef = Firestore.instance.collection('tasks');

  Future<List<User>> fetchUsers() async {
    List<User> users;
    var result = await _usersCollectionRef.getDocuments();
    users = result.documents
        .map((doc) => User.fromMap(doc.data))
        .toList();
    return users;
  }

  Future<List<ProviderUser>> fetchProviders() async {
    List<ProviderUser> providers;
    var result = await _providersCollectionRef.getDocuments();
    providers = result.documents.map((doc) => ProviderUser.fromMap(doc.data)).toList();
    return providers;
  }

  Future<List<Task>> fetchTasks() async {
    List<Task> tasks;
    var result = await _taskCollectionRef.getDocuments();
    tasks = result.documents.map((doc) => Task.fromMap(doc.data)).toList();
    return tasks;
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
    DocumentSnapshot doc = await _providersCollectionRef.document(pid).get();
    return ProviderUser.fromMap(doc.data);
  }

  Future<Task> getTaskById({String taskId}) async {
    DocumentSnapshot doc = await _taskCollectionRef.document(taskId).get();
    return Task.fromMap(doc.data);
  }

  Stream<QuerySnapshot> streamUserChatsAndProviders({List<dynamic> chatIds}) {
    return _chatCollectionRef.where('uid', arrayContainsAny: chatIds).orderBy('time', descending: true).snapshots();
  }

  Future<Map<Chat, ProviderUser>> getUserChatsAndProviders({List<dynamic> chatIds}) async {

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

  Future updateTask({Task task, String taskId}) async {
    await _taskCollectionRef.document(taskId).setData(task.toJson(),merge: true);
  }

  Future<DocumentReference> addTask({@required Task task, @required String uid}) async {

    DocumentReference result = await _taskCollectionRef.add(task.toJson()).then((docRef) async {
      await updateTask(task: Task(taskId: docRef.documentID), taskId: docRef.documentID,);
      await _usersCollectionRef.document(uid).setData({'posts':FieldValue.arrayUnion([docRef.documentID])},merge: true);
      return docRef;
    });

    return result;

  }

  Future addMessageToChat({String chatId, ChatMessage chatMessage, bool providerIsSender}) async {

    Chat chat = Chat(lastMessage: chatMessage.text, time: chatMessage.time, isHiddenFromProvider: false, isHiddenFromUser: false);

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

    Chat chat = Chat(uid: uid, pid: pid, providerdsUid: providersUid, isHiddenFromUser: false, isHiddenFromProvider:  false);

    DocumentReference result = await _chatCollectionRef.add(chat.toJson()).then( (docRef) async {
      await updateChat(chat: Chat(chatid: docRef.documentID));
      await _usersCollectionRef.document(uid).setData({'chats': FieldValue.arrayUnion([docRef.documentID])},merge: true);
      await _providersCollectionRef.document(pid).setData({'chats': FieldValue.arrayUnion([docRef.documentID])},merge: true);
      return docRef;
    });

    return result;
  }

  Future<DocumentReference> applyToTask({@required String taskId, @required String providerId, @required String userId}) async {
    if(debugMode) print('FirestoreAPI: applyToTask called for task $taskId by applicant $providerId');
    await _taskCollectionRef.document(taskId).setData({'applicantIds': FieldValue.arrayUnion([providerId])},merge: true);
    await _providersCollectionRef.document(providerId).setData({'tasksApplied': FieldValue.arrayUnion([taskId])},merge: true);
    await _usersCollectionRef.document(userId).setData({'providerAppliedTasks': FieldValue.arrayUnion([taskId])},merge: true);
  }

  Future<DocumentReference> removeUserFavourite({String uid, String favouritePid}) async {
    if(debugMode) print('FirestoreAPI: removeUserFavourite called for hirer $uid on provider $favouritePid');
    await _usersCollectionRef.document(uid).setData({'favourites' : FieldValue.arrayRemove([favouritePid])},merge: true);
    await _providersCollectionRef.document(favouritePid).setData({'isFavouritedBy' : FieldValue.arrayRemove([uid])},merge: true);
  }

  Future<DocumentReference> addUserFavourite({String uid, String favouritePid}) async {
    if(debugMode) print('FirestoreAPI: addUserFavourite called for hirer $uid on provider $favouritePid');
    await _usersCollectionRef.document(uid).setData({'favourites' : FieldValue.arrayUnion([favouritePid])},merge: true);
    await _providersCollectionRef.document(favouritePid).setData({'isFavouritedBy' : FieldValue.arrayUnion([uid])},merge: true);
  }

  Future<List<ProviderUser>> getUsersProviders({List usersPids}) async {
    List<ProviderUser> providers = [];
    for (var pid in usersPids) {
      providers.add(await getProviderById(pid));
    }
    return providers;
  }

  Future<List<Task>> getTasks({List postIds}) async {
    if(debugMode) print('FirestoreAPI: getTasks called for $postIds');
    List<Task> tasks = [];
    for(var taskId in postIds) {
      tasks.add(await getTaskById(taskId: taskId));
    }
    return tasks;
  }

  Future<List<Task>> getProviderTasks({List pids}) async {
    if(debugMode) print('FirestoreAPI: getProviderTasks called for $pids');
    List<ProviderUser> providers = await getUsersProviders(usersPids: pids);
    List<Task> tasks = [];
    for(ProviderUser provider in providers) {
      tasks.addAll(await getTasks(postIds: provider.tasksApplied));
    }

    return tasks;
  }


  Future<void> deleteProvider({ProviderUser provider}) async {

    //TODO: may be worth doing try and catch blocks here!!!!!!!!!!
    if(debugMode) print('FirestoreAPI: deleteProvider called on ${provider.pid}');

    if(provider.chats.isNotEmpty) for(String chatID in provider.chats) {
      if(debugMode) print('FirestoreAPI: Deleting chat $chatID}');
      //TODO: currently the chat gets deleted and also from the hirer's array, would be better to provide feedback to the hirer
      Chat chat = await getChatById(chatID);
      await deleteChat(chat: chat);
    }

    if(provider.isFavouritedBy.isNotEmpty) for(String uid in provider.isFavouritedBy) {
      if(debugMode) print('FirestoreAPI: Removing provider from hirer: $uid favourites');
      await removeUserFavourite(uid: uid, favouritePid: provider.pid);
    }

    //Delete the provider
    await _providersCollectionRef.document(provider.pid).delete();
    //Remove provider from users array
    await _usersCollectionRef.document(provider.uid).setData({'providerProfiles': FieldValue.arrayRemove([provider.pid])},merge: true);
    if(debugMode) print('FirestoreAPI: deleteProvider complete');
  }


  Future<void> deleteChat({Chat chat}) async {
    await _chatCollectionRef.document(chat.chatid).delete();
    await _providersCollectionRef.document(chat.pid).setData({'chats': FieldValue.arrayRemove([chat.chatid])},merge: true);
    await _usersCollectionRef.document(chat.uid).setData({'chats': FieldValue.arrayRemove([chat.chatid])},merge: true);
  }

  Future<void> deleteUserDisplayPicture({User user}) async {
    await FirebaseStorage.instance.ref().child(user.displayPictureFileName).delete();
    await _usersCollectionRef.document(user.id).setData({'displayPictureFileName': FieldValue.delete(),'displayPictureURL':FieldValue.delete()},merge: true);
  }

  Future<void> deleteProviderDisplayPicture({ProviderUser provider}) async {
    await FirebaseStorage.instance.ref().child(provider.displayPictureFileName).delete();
    await _providersCollectionRef.document(provider.pid).setData({'displayPictureFileName': FieldValue.delete(),'displayPictureURL':FieldValue.delete()},merge: true);
  }

  Future<void> hideChat({Chat chat, bool forProvider}) async {
    if(debugMode) print('FirestoreAPI: hideChat called');
    forProvider ? chat.isHiddenFromProvider = true : chat.isHiddenFromUser = true;
    print(chat.isHiddenFromUser);
    print(chat.isHiddenFromProvider);
     await updateChat(chat: chat);
  }


}

