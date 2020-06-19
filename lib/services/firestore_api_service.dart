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


class FirestoreAPIService {
  CollectionReference _usersCollectionRef =
      Firestore.instance.collection('users');
  CollectionReference _providersCollectionRef =
      Firestore.instance.collection('providers');
  CollectionReference _chatCollectionRef =
      Firestore.instance.collection('chats');
  CollectionReference _taskCollectionRef =
      Firestore.instance.collection('tasks');

  Future<List<User>> fetchUsers() async {
    List<User> users;
    var result = await _usersCollectionRef.getDocuments();
    users = result.documents.map((doc) => User.fromMap(doc.data)).toList();
    return users;
  }

  Future<List<ProviderUser>> fetchProviders() async {
    List<ProviderUser> providers;
    var result = await _providersCollectionRef.getDocuments();
    providers =
        result.documents.map((doc) => ProviderUser.fromMap(doc.data)).toList();
    return providers;
  }

  Future<List<ProviderUser>> getProvidersByService({String serviceType}) async {
    QuerySnapshot result = await _providersCollectionRef
        .where('type', isEqualTo: serviceType)
        .getDocuments();
    List<ProviderUser> allProviders =
        result.documents.map((doc) => ProviderUser.fromMap(doc.data)).toList();
    return allProviders;
  }

  Future<List<Map<String, dynamic>>> fetchTasksAndHirers({List taskIds}) async {
    if (debugMode) print('FirestoreAPI: fetchTasksAndHirers called');

    ///This function is for fetching all the tasks for the tasks feed

    List<Map<String, dynamic>> tasksAndHirers = [];
    List<Task> tasks;
    var result = await _taskCollectionRef.getDocuments();
    tasks = result.documents.map((doc) => Task.fromMap(doc.data)).toList();
    tasks.sort((a, b) => b.time.compareTo(a.time));
    for (Task task in tasks) {
      Map<String, dynamic> taskAndHirer = {};
      taskAndHirer['task'] = task;
      taskAndHirer['hirer'] = await getUserById(task.hirerId);
      tasksAndHirers.add(taskAndHirer);
    }
    return tasksAndHirers;
  }

  Stream<QuerySnapshot> fetchChatStream(String chatId) {
    return _chatCollectionRef
        .document(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
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

  Future<DocumentSnapshot> getTaskById123({String taskId}) async {
    DocumentSnapshot doc = await _taskCollectionRef.document(taskId).get();
    return doc;
  }

  Stream<QuerySnapshot> streamUserChatsAndProviders({List<dynamic> chatIds}) {
    return _chatCollectionRef
        .where('uid', arrayContainsAny: chatIds)
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getChatsAndProviders(
      {List<dynamic> chatIds}) async {
    if (debugMode) print('FirestoreAPI: getChatsAndProviders called');
    List<Map<String, dynamic>> chatsAndProviders = [];

    List<Chat> chats = [];

    for (String chatId in chatIds) {
      if (debugMode) print('FirestoreAPI: getChatsAndProviders getting chat $chatId');
      Chat chat = await getChatById(chatId);
      chats.add(chat);
    }

    chats.sort((a, b) => b.time.compareTo(a.time));
    print('');

    for (Chat chat in chats) {
      Map<String, dynamic> chatAndProvider = {};
      if (debugMode) print('FirestoreAPI: getChatsAndProviders getting provider ${chat.pid}');
      ProviderUser provider = await getProviderById(chat.pid);
      chatAndProvider['chat'] = chat;
      chatAndProvider['provider'] = provider;
      chatsAndProviders.add(chatAndProvider);
    }
    return chatsAndProviders;
  }

  Future<List<Map<String, dynamic>>> getTaskChatsAndProviders(
      {List<dynamic> chatIdsAndPids}) async {
    if (debugMode) print('FirestoreAPI: getTaskChatsAndProviders called');

    List<Map<String, dynamic>> chatAndProviders = [];
    List<Chat> chats = [];

    if (chatIdsAndPids.isNotEmpty)
      for (Map chatAndPid in chatIdsAndPids) {
        Map<String, dynamic> chatAndProvider = {};
        //TODO don't like green text here...
        if (debugMode)
          print(
              'FirestoreAPI: getTaskChatsAndProviders found applicant with chat ${chatAndPid['chatId']} and provider ${chatAndPid['pid']}');
        Chat chat = await getChatById(chatAndPid['chatId']);
        ProviderUser provider = await getProviderById(chatAndPid['pid']);
        chatAndProvider['chat'] = chat;
        chatAndProvider['provider'] = provider;

        chatAndProviders.add(chatAndProvider);
      }

    chatAndProviders.sort((a, b) {
      Chat chatB = b['chat'];
      Chat chatA = a['chat'];
      return chatB.time.compareTo(chatA.time);
    });

    return chatAndProviders;
  }

  Future<List<Map<String, dynamic>>> getUserProviderChatsAndHirers(
      {List<dynamic> usersPids}) async {
    if (debugMode) print('FirestoreAPI: getUserProviderChatsAndHirers called');
    List<Map<String, dynamic>> userProviderChatsAndUsers = [];

    for (String pid in usersPids) {
      List<Chat> providerChats = [];
      if (debugMode)
        print(
            'FirestoreAPI: getUserProviderChatsAndHirers searching chats for pid $pid');
      Map<Chat, User> chatsAndUsers = {};
      ProviderUser provider = await getProviderById(pid);

      if (provider.chats.isNotEmpty) {
        for (String chatId in provider.chats) {
          if (debugMode)
            print(
                'FirestoreAPI: getUserProviderChatsAndHirers pid $pid has chat $chatId');
          Chat chat = await getChatById(chatId);
          providerChats.add(chat);
        }
      }

      for (Chat chat in providerChats) {
        Map<String, dynamic> providerChatHirer = {};
        User chatUser = await getUserById(chat.uid);
        providerChatHirer['chat'] = chat;
        providerChatHirer['provider'] = provider;
        providerChatHirer['hirer'] = chatUser;
        userProviderChatsAndUsers.add(providerChatHirer);
      }
    }

    userProviderChatsAndUsers.sort((a, b) {
      Chat chatB = b['chat'];
      Chat chatA = a['chat'];
      return chatB.time.compareTo(chatA.time);
    });

    return userProviderChatsAndUsers;
  }

  Future updateUser({User user, String uid}) async {
    await _usersCollectionRef.document(uid).setData(user.toJson(), merge: true);
    return;
  }

  Future updateProvider({ProviderUser provider, String pid}) async {
    await _providersCollectionRef
        .document(pid)
        .setData(provider.toJson(), merge: true);
    return;
  }

  Future updateTask({Task task, String taskId}) async {
    await _taskCollectionRef
        .document(taskId)
        .setData(task.toJson(), merge: true);
    return;
  }

  Future updateChat({Chat chat}) async {
    await _chatCollectionRef
        .document(chat.chatid)
        .setData(chat.toJson(), merge: true);
  }

  Future addUserByID(User user) async {
    var result =
        await _usersCollectionRef.document(user.id).setData(user.toJson());
    return;
  }


  Future addUser(User user) async {
    var result = await _usersCollectionRef.add(user.toJson());
    return result;
  }

  Future<DocumentReference> addTask(
      {@required Task task, @required String uid}) async {
    DocumentReference result =
        await _taskCollectionRef.add(task.toJson()).then((docRef) async {
      await updateTask(
        task: Task(taskId: docRef.documentID),
        taskId: docRef.documentID,
      );
      await _usersCollectionRef.document(uid).setData({
        'posts': FieldValue.arrayUnion([docRef.documentID])
      }, merge: true);
      return docRef;
    });

    return result;
  }

  Future addMessageToChat(
      {String chatId, ChatMessage chatMessage, bool providerIsSender}) async {
    Chat chat = Chat(
        lastMessage: chatMessage.text,
        time: chatMessage.time,
        isHiddenFromProvider: false,
        isHiddenFromUser: false);

    providerIsSender
        ? chat.userHasUnreadMessage = true
        : chat.providerHasUnreadMessage = true;

    await _chatCollectionRef
        .document(chatId)
        .setData(chat.toJson(), merge: true);
    var result = await _chatCollectionRef
        .document(chatId)
        .collection('messages')
        .add(chatMessage.toJson());
  }

  Future<DocumentReference> addProvider(
      ProviderUser provider, String uid) async {
    DocumentReference result = await _providersCollectionRef
        .add(provider.toJson())
        .then((docRef) async {
      await updateProvider(
        provider: ProviderUser(pid: docRef.documentID),
        pid: docRef.documentID,
      );
      await _usersCollectionRef.document(uid).setData({
        'providerProfiles': FieldValue.arrayUnion([docRef.documentID])
      }, merge: true);
      return docRef;
    });

    return result;
  }

  Future<DocumentReference> addNewChat({String uid, String pid}) async {
    Chat chat = Chat(
        uid: uid,
        pid: pid,
        isHiddenFromUser: false,
        isHiddenFromProvider: false,
        isForTask: false);

    DocumentReference result =
        await _chatCollectionRef.add(chat.toJson()).then((docRef) async {
      await updateChat(chat: Chat(chatid: docRef.documentID));
      await _usersCollectionRef.document(uid).setData({
        'chats': FieldValue.arrayUnion([docRef.documentID])
      }, merge: true);
      await _providersCollectionRef.document(pid).setData({
        'chats': FieldValue.arrayUnion([docRef.documentID])
      }, merge: true);
      return docRef;
    });

    return result;
  }

  Future<DocumentReference> applyToTask(
      {@required String taskId,
      @required String providerId,
      @required String userId}) async {
    if (debugMode)
      print('FirestoreAPI: applyToTask called for task $taskId by applicant $providerId');

    Chat chat = Chat(
        taskid: taskId,
        uid: userId,
        pid: providerId,
        isHiddenFromUser: false,
        isHiddenFromProvider: false,
        isForTask: true);
    DocumentReference chatResult =
        await _chatCollectionRef.add(chat.toJson()).then((docRef) async {
      await updateChat(chat: Chat(chatid: docRef.documentID));
      return docRef;
    });

    //TODO, can we please make arrayUnion func under the class (what if the green names change)
    await _taskCollectionRef.document(taskId).setData({
      'applicantChatsAndPids': FieldValue.arrayUnion([
        {'chatId': chatResult.documentID, 'pid': providerId}
      ])
    }, merge: true);

    await _providersCollectionRef.document(providerId).setData({
      'tasksApplied': FieldValue.arrayUnion([taskId])
    }, merge: true);

    return chatResult;
  }


  Future<DocumentReference> removeTaskApplicant({@required String providerId, @required String chatId, @required String taskId}) async {
    if(debugMode) print('FirestoreAPI: removeTaskApplicant called for task $taskId by provider $providerId');
    ///Remove from task array
    await _taskCollectionRef.document(taskId).setData({'applicantChatsAndPids': FieldValue.arrayRemove([
      {'chatId': chatId, 'pid': providerId}
    ])},merge: true);

    ///Remove from provider array
    await _providersCollectionRef.document(providerId).setData({'tasksApplied':FieldValue.arrayRemove([taskId])},merge: true);

    ///Delete all subcollection messages
    await _chatCollectionRef
        .document(chatId)
        .collection('messages')
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isNotEmpty)
        for (DocumentSnapshot doc in snapshot.documents) {
          doc.reference.delete();
        }
    });

    ///Deleting the chat
    await _chatCollectionRef.document(chatId).delete();

  }

  Future<DocumentReference> removeUserFavourite(
      {String uid, String favouritePid}) async {
    if (debugMode)
      print(
          'FirestoreAPI: removeUserFavourite called for hirer $uid on provider $favouritePid');
    await _usersCollectionRef.document(uid).setData({
      'favourites': FieldValue.arrayRemove([favouritePid])
    }, merge: true);
    await _providersCollectionRef.document(favouritePid).setData({
      'isFavouritedBy': FieldValue.arrayRemove([uid])
    }, merge: true);
  }

  Future<DocumentReference> addUserFavourite(
      {String uid, String favouritePid}) async {
    if (debugMode)
      print(
          'FirestoreAPI: addUserFavourite called for hirer $uid on provider $favouritePid');
    await _usersCollectionRef.document(uid).setData({
      'favourites': FieldValue.arrayUnion([favouritePid])
    }, merge: true);
    await _providersCollectionRef.document(favouritePid).setData({
      'isFavouritedBy': FieldValue.arrayUnion([uid])
    }, merge: true);
  }

  Future<List<ProviderUser>> getProviders({List pids}) async {
    List<ProviderUser> providers = [];
    for (var pid in pids) {
      providers.add(await getProviderById(pid));
    }
    return providers;
  }

  Future<List<Task>> getTasks({List postIds}) async {
    if (debugMode) print('FirestoreAPI: getTasks called for $postIds');
    List<Task> tasks = [];
    for (var taskId in postIds) {
      tasks.add(await getTaskById(taskId: taskId));
    }
    tasks.sort((a, b) => b.time.compareTo(a.time));
    return tasks;
  }

  Future<List<Map<String, dynamic>>> getProviderTasksAndHirers(
      {List pids}) async {
    ///This function takes a list pids and gets the tasks applied for by each provider

    if (debugMode) print('FirestoreAPI: getProviderTasks called for $pids');

    List<Map<String, dynamic>> tasksAndHirers = [];
    List<Task> tasks = [];

    List<ProviderUser> providers = await getProviders(pids: pids);
    for (ProviderUser provider in providers) {
      tasks.addAll(await getTasks(postIds: provider.tasksApplied));
    }
    tasks.sort((a, b) => b.time.compareTo(a.time));
    for (Task task in tasks) {
      Map<String, dynamic> taskAndHirer = {};
      taskAndHirer['task'] = task;
      taskAndHirer['hirer'] = await getUserById(task.hirerId);
      tasksAndHirers.add(taskAndHirer);
    }

    return tasksAndHirers;
  }

  Future<void> deleteProvider({ProviderUser provider}) async {
    //TODO: may be worth doing try and catch blocks here!!!!!!!!!!
    if (debugMode)
      print('FirestoreAPI: deleteProvider called on ${provider.pid}');

    if (provider.chats.isNotEmpty)
      for (String chatID in provider.chats) {
        if (debugMode) print('FirestoreAPI: deleteProvider Deleting chat $chatID}');
        //TODO: currently the chat gets deleted and also from the hirer's array, would be better to provide feedback to the hirer
        Chat chat = await getChatById(chatID);
        await deleteChat(chat: chat);
      }

    ///Remove provider from any hirer favourites
    if (provider.isFavouritedBy.isNotEmpty)
      for (String uid in provider.isFavouritedBy) {
        if (debugMode)
          print('FirestoreAPI: deleteProvider Removing provider from hirer: $uid favourites');
        await removeUserFavourite(uid: uid, favouritePid: provider.pid);
      }

    ///Remove provider from tasks they have applied to
    if(provider.tasksApplied.isNotEmpty) for(String taskId in provider.tasksApplied) {
      if(debugMode) print('FirestoreAPI: deleteProvider Removing provider application from task $taskId');
      Task appliedTask = await getTaskById(taskId: taskId);
      String chatId = appliedTask.applicantChatsAndPids.where((element) => element['pid'] == provider.pid).elementAt(0)['chatId'];
      await removeTaskApplicant(providerId: provider.pid, chatId: chatId, taskId: taskId);
    }

    ///Delete the provider
    await _providersCollectionRef.document(provider.pid).delete();

    ///Remove provider from users array
    await _usersCollectionRef.document(provider.uid).setData({
      'providerProfiles': FieldValue.arrayRemove([provider.pid])
    }, merge: true);
    if (debugMode) print('FirestoreAPI: deleteProvider complete');
  }

  Future<void> deleteChat({Chat chat}) async {
    ///Deleting chat from provider's array
    await _providersCollectionRef.document(chat.pid).setData({
      'chats': FieldValue.arrayRemove([chat.chatid])
    }, merge: true);

    ///Deleting chat from hirer's array
    await _usersCollectionRef.document(chat.uid).setData({
      'chats': FieldValue.arrayRemove([chat.chatid])
    }, merge: true);

    ///Deleting messages attached to the chat
    await _chatCollectionRef
        .document(chat.chatid)
        .collection('messages')
        .getDocuments()
        .then((snapshot) {
      if (snapshot.documents.isNotEmpty)
        for (DocumentSnapshot doc in snapshot.documents) {
          doc.reference.delete();
        }
    });

    ///Deleting the chat
    await _chatCollectionRef.document(chat.chatid).delete();
  }



  Future<void> deleteUserDisplayPicture({User user}) async {
    await FirebaseStorage.instance
        .ref()
        .child(user.displayPictureFileName)
        .delete();
    await _usersCollectionRef.document(user.id).setData({
      'displayPictureFileName': FieldValue.delete(),
      'displayPictureURL': FieldValue.delete()
    }, merge: true);
  }

  Future<void> deleteProviderDisplayPicture({ProviderUser provider}) async {
    await FirebaseStorage.instance
        .ref()
        .child(provider.displayPictureFileName)
        .delete();
    await _providersCollectionRef.document(provider.pid).setData({
      'displayPictureFileName': FieldValue.delete(),
      'displayPictureURL': FieldValue.delete()
    }, merge: true);
  }

  Future<void> hideChat({Chat chat, bool forProvider}) async {
    if (debugMode) print('FirestoreAPI: hideChat called');
    forProvider
        ? chat.isHiddenFromProvider = true
        : chat.isHiddenFromUser = true;
    print(chat.isHiddenFromUser);
    print(chat.isHiddenFromProvider);
    await updateChat(chat: chat);
  }
}
