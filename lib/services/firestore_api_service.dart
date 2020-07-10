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

//TODO WE HAVE TO CHANGE SET DATA TO UPDATE DATA, AS OTHERWISE NEW DOCUMENTS ARE CREATED!!!!

class FirestoreAPIService {
  CollectionReference _usersCollectionRef =
      Firestore.instance.collection('users');
  CollectionReference _providersCollectionRef =
      Firestore.instance.collection('providers');
  CollectionReference _chatCollectionRef =
      Firestore.instance.collection('chats');
  CollectionReference _taskCollectionRef =
      Firestore.instance.collection('tasks');

  final String applicantCollectionName = 'applicants';

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

  Future<List<Map<String, dynamic>>> fetchTasksAndHirers() async {
    if (debugMode) print('FirestoreAPI: fetchTasksAndHirers called');

    ///This function is for fetching all the tasks for the tasks feed

    List<Map<String, dynamic>> tasksAndHirers = [];
    List<Task> tasks;
    var result = await _taskCollectionRef.getDocuments();

    ///Map all the documents into Task objects
    tasks = result.documents.map((doc) => Task.fromMap(doc.data)).toList();

    ///Sort by time posted
    tasks.sort((a, b) => b.time.compareTo(a.time));
    for (Task task in tasks) {
      Map<String, dynamic> taskAndHirer = {};
      taskAndHirer['task'] = task;
      var hirer = await getUserById(task.hirerId);

      ///If hirer exists add them to the task list
      if (hirer != null) {
        taskAndHirer['hirer'] = hirer;
        tasksAndHirers.add(taskAndHirer);
      }
    }
    return tasksAndHirers;
  }

  Future<List<Map<String, dynamic>>> fetchTasksAndHirersByService({String service}) async {
    if (debugMode) print('FirestoreAPI: fetchTasksAndHirersByService called on service $service');

    ///This function is for fetching all the tasks for the tasks feed

    List<Map<String, dynamic>> tasksAndHirers = [];
    List<Task> tasks;
    var result = await _taskCollectionRef.where('service', isEqualTo: service).getDocuments();

    ///Map all the documents into Task objects
    tasks = result.documents.map((doc) => Task.fromMap(doc.data)).toList();

    ///Sort by time posted
    tasks.sort((a, b) => b.time.compareTo(a.time));
    for (Task task in tasks) {
      Map<String, dynamic> taskAndHirer = {};
      taskAndHirer['task'] = task;
      var hirer = await getUserById(task.hirerId);

      ///If hirer exists add them to the task list
      if (hirer != null) {
        taskAndHirer['hirer'] = hirer;
        tasksAndHirers.add(taskAndHirer);
      }
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

  Stream<QuerySnapshot> fetchTaskApplicantChatStream(
      {@required String taskid, @required String applicantId}) {
    return _taskCollectionRef
        .document(taskid)
        .collection(applicantCollectionName)
        .document(applicantId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future getChatById(String chatId) async {
    var doc = await _chatCollectionRef.document(chatId).get();
    return doc.exists ? Chat.fromMap(doc.data) : null;
  }

  Future getUserById(String uid) async {
    var doc = await _usersCollectionRef.document(uid).get();
    return doc.exists ? User.fromMap(doc.data) : null;
  }

  Future getProviderById(String pid) async {
    if (debugMode) print('FirestoreAPI: getProviderById called on $pid');
    DocumentSnapshot doc = await _providersCollectionRef.document(pid).get();
    return doc.exists ? ProviderUser.fromMap(doc.data) : null;
  }

  Future getTaskById({String taskId}) async {
    DocumentSnapshot doc = await _taskCollectionRef.document(taskId).get();
    return doc.exists ? Task.fromMap(doc.data) : null;
  }

  Future getTaskApplicantById({String taskId, String applicantId}) async {
    DocumentSnapshot doc = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicantId)
        .get();

    return doc.exists ? TaskApplicant.fromMap(doc.data) : null;
  }

  Future<bool> providerApplicationHasNotification(
      {@required String taskId, @required String pid}) async {
    bool hasNotification = false;

    ///Don't need to worry too much about this document not existing as
    ///it is only called for the tasks that the provider has applied to
    QuerySnapshot docs = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .where('pid', isEqualTo: pid)
        .getDocuments();

    if (docs.documents.isNotEmpty)
      for (DocumentSnapshot doc in docs.documents) {
        TaskApplicant taskApplicant = TaskApplicant.fromMap(doc.data);

        ///If the taskapplicant has an unread messages then mark has notification as true
        if (taskApplicant.providerHasUnreadMessage) hasNotification = true;
      }

    return hasNotification;
  }

  Future<bool> hirerTaskHasNotification({@required String taskId}) async {
    bool hasNotification = false;

    ///Don't need to worry too much about this document not existing as
    ///it is only called for the tasks that the provider has applied to
    QuerySnapshot docs = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .getDocuments();

    if (docs.documents.isNotEmpty)
      for (DocumentSnapshot doc in docs.documents) {
        TaskApplicant taskApplicant = TaskApplicant.fromMap(doc.data);

        ///If the hirer has an unread messages then mark has notification as true
        if (taskApplicant.hirerHasUnreadMessage) hasNotification = true;
      }

    return hasNotification;
  }

  Future<List<ProviderUser>> getUsersFavourites(userFavourites) async {
    List<ProviderUser> providers = [];
    if (debugMode)
      print(
          'FirestoreAPIService: getUserFavourites called on: $userFavourites ');
    for (var pid in userFavourites) {
      ProviderUser favProvider = await getProviderById(pid);

      ///Check that the provider exists
      if (favProvider != null) {
        providers.add(favProvider);
      }
    }
    providers.sort((a, b) => a.type.compareTo(b.type));
    return providers;
  }

  Stream streamUserChatsAndProviders({String userId}) {
    ///This function is used to stream a users chat summary screen
    if (debugMode) print('firestoreApi: streamUserChatsAndProviders called');

    Stream chatStream = _chatCollectionRef
        .where('uid', isEqualTo: userId)
        .orderBy('time', descending: true)
        .snapshots()
        .asyncMap((event) async {

          //TODO look to see if we can just call getproviderbyid on the docs that have changed (while still chaching old docs)
      var futures = event.documents.map((doc) async {
        Chat chat = Chat.fromMap(doc.data);
        ProviderUser provider = await getProviderById(chat.pid);

        if (provider != null) {
          return {'chat': chat, 'provider': provider};
        } else
          return null;
      });

      return await Future.wait(futures);
    });

    return chatStream;

  }



  Stream streamUserProviderChatsAndHirers({List userPids} ){
    ///This function is used to stream a users provider chat summaries
    if (debugMode) print('firestoreApi: streamUserProviderChatsAndHirers called');

    Stream chatStream = _chatCollectionRef
        .where('pid', whereIn: userPids)
        .orderBy('time', descending: true)
        .snapshots()
        .asyncMap((event) async {

      //TODO look to see if we can just call getproviderbyid on the docs that have changed (while still chaching old docs)
      var futures = event.documents.map((doc) async {
        Chat chat = Chat.fromMap(doc.data);
        ProviderUser provider = await getProviderById(chat.pid);
        User hirer = await getUserById(chat.uid);

        if (provider != null && hirer != null) {
          return {'chat': chat, 'provider': provider, 'hirer':hirer};
        } else
          return null;
      });

      return await Future.wait(futures);

    });


    return chatStream;
  }

  Future<List<Map<String, dynamic>>> getChatsAndProviders(
      {List<dynamic> chatIds}) async {
    ///This is called to get a hirers private messages
    if (debugMode) print('FirestoreAPI: getChatsAndProviders called');
    List<Map<String, dynamic>> chatsAndProviders = [];

    List<Chat> chats = [];

    for (String chatId in chatIds) {
      if (debugMode)
        print('FirestoreAPI: getChatsAndProviders getting chat $chatId');
      Chat chat = await getChatById(chatId);

      ///Check that the chat exists
      if (chat != null) {
        chats.add(chat);
      }
    }

    chats.sort((a, b) => b.time.compareTo(a.time));
    print('');

    for (Chat chat in chats) {
      Map<String, dynamic> chatAndProvider = {};
      if (debugMode)
        print(
            'FirestoreAPI: getChatsAndProviders getting provider ${chat.pid}');
      ProviderUser provider = await getProviderById(chat.pid);

      ///Check that the provider exists
      if (provider != null) {
        chatAndProvider['chat'] = chat;
        chatAndProvider['provider'] = provider;
        chatsAndProviders.add(chatAndProvider);
      }
    }
    if (debugMode) print('FirestoreAPI: getChatsAndProviders finished');
    return chatsAndProviders;
  }

  Future<List<Map<String, dynamic>>> getTaskApplicants(
      {@required String taskId}) async {
    ///This is called to get the applicants attached to a task
    if (debugMode) print('FirestoreAPI: getTaskApplicants called on $taskId');

    List<Map<String, dynamic>> applicationAndProviders = [];

    QuerySnapshot applicants = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .getDocuments();

    if (applicants.documents.isNotEmpty) {
      ///Map all the documents into Task objects
      List<TaskApplicant> tasksApplicants = applicants.documents
          .map((doc) => TaskApplicant.fromMap(doc.data))
          .toList();

      for (TaskApplicant applicant in tasksApplicants) {
        Map<String, dynamic> applicationAndProvider = {};

        if (debugMode)
          print(
              'FirestoreAPI: getTaskChatsAndProviders found application ${applicant.applicationId} and provider ${applicant.pid}');

        ///Grab the provider associated with the application
        ProviderUser provider = await getProviderById(applicant.pid);

        ///Check that the provider exists
        if (provider != null) {
          applicationAndProvider['applicant'] = applicant;
          applicationAndProvider['provider'] = provider;
          applicationAndProviders.add(applicationAndProvider);
        }
      }

      applicationAndProviders.sort((a, b) {
        TaskApplicant taskA = a['applicant'];
        TaskApplicant taskB = b['applicant'];
        return taskB.time.compareTo(taskA.time);
      });
    }

    return applicationAndProviders;
  }

  Future<List<Map<String, dynamic>>> getUserProviderChatsAndHirers(
      {List<dynamic> usersPids}) async {
    ///This is called to get the chats associated with a users provider accounts
    if (debugMode) print('FirestoreAPI: getUserProviderChatsAndHirers called');
    List<Map<String, dynamic>> userProviderChatsAndUsers = [];

    for (String pid in usersPids) {
      List<Chat> providerChats = [];
      if (debugMode)
        print(
            'FirestoreAPI: getUserProviderChatsAndHirers searching chats for pid $pid');
      ProviderUser provider = await getProviderById(pid);

      ///Check that the provider exists and that they have chats
      if ((provider != null) && (provider.chats.isNotEmpty)) {
        for (String chatId in provider.chats) {
          if (debugMode)
            print(
                'FirestoreAPI: getUserProviderChatsAndHirers pid $pid has chat $chatId');
          Chat chat = await getChatById(chatId);

          ///Check that the chat exists
          if (chat != null) {
            providerChats.add(chat);
          }
        }
      }

      for (Chat chat in providerChats) {
        Map<String, dynamic> providerChatHirer = {};
        User chatUser = await getUserById(chat.uid);

        ///Check that the chatUser exists
        if (chatUser != null) {
          providerChatHirer['chat'] = chat;
          providerChatHirer['provider'] = provider;
          providerChatHirer['hirer'] = chatUser;
          userProviderChatsAndUsers.add(providerChatHirer);
        }
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

  Future updateTaskApplicant({TaskApplicant taskApplicant}) async {
    await _taskCollectionRef
        .document(taskApplicant.taskid)
        .collection(applicantCollectionName)
        .document(taskApplicant.applicationId)
        .setData(taskApplicant.toJson(), merge: true);
  }

  Future addUserByID(User user) async {
    var result =
        await _usersCollectionRef.document(user.id).setData(user.toJson());
    return result;
  }

  Future addUser(User user) async {
    var result = await _usersCollectionRef.add(user.toJson());
    return result;
  }

  //TODO how to fail safe this ???
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

    return result;
  }

  Future addMessageToTaskApplicant(
      {@required String applicantId,
      @required ChatMessage chatMessage,
      @required bool providerIsSender,
      @required String taskId}) async {
    TaskApplicant taskApplicant = TaskApplicant(
        lastMessage: chatMessage.text,
        time: chatMessage.time,
        isHiddenFromProvider: false,
        isHiddenFromHirer: false);

    providerIsSender
        ? taskApplicant.hirerHasUnreadMessage = true
        : taskApplicant.providerHasUnreadMessage = true;

    ///Update the taskApplicant data
    await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicantId)
        .setData(taskApplicant.toJson(), merge: true);

    ///Add the message to the task applicant collection
    var result = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicantId)
        .collection('messages')
        .add(chatMessage.toJson());

    ///If the sender was a provider, mark the task hasNotifications as true
    ///We can do this as a cloud function
//    if (providerIsSender) {
//      Task updatedTask = Task(hasNotifications: true);
//      await _taskCollectionRef
//          .document(taskId)
//          .setData(updatedTask.toJson(), merge: true);
//    }

    return result;
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
        isHiddenFromProvider: false);

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
      print(
          'FirestoreAPI: applyToTask called for task $taskId by applicant $providerId');

    TaskApplicant taskApplicant = TaskApplicant(
        taskid: taskId,
        hirerid: userId,
        pid: providerId,
        isHiddenFromHirer: false,
        isHiddenFromProvider: false);

    ///Add applicant to task collection
    DocumentReference taskApplicantResult = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .add(taskApplicant.toJson())
        .then((docRef) async {
      await updateTaskApplicant(
          taskApplicant:
              TaskApplicant(applicationId: docRef.documentID, taskid: taskId));
      return docRef;
    });

    ///Add applicant to provider's tasksApplied
    await _providersCollectionRef.document(providerId).setData({
      'tasksApplied': FieldValue.arrayUnion([taskId])
    }, merge: true);
    return taskApplicantResult;
  }

  Future removeTaskApplicant({
    @required String providerId,
    @required String taskId,
    @required String applicationId,
  }) async {
    if (debugMode)
      print(
          'FirestoreAPI: removeTaskApplicant called for task $taskId by provider $providerId');

    ///Remove from provider's array
    await _providersCollectionRef.document(providerId).setData({
      'tasksApplied': FieldValue.arrayRemove([taskId])
    }, merge: true);

    ///Delete all subcollection messages
    await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicationId)
        .collection('messages')
        .getDocuments()
        .then((snapshot) async {
      if (snapshot.documents.isNotEmpty)
        for (DocumentSnapshot doc in snapshot.documents) {
          await doc.reference.delete();
        }
    });

    ///Deleting the application
    await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicationId)
        .delete();
  }

  Future<void> deleteTask({Task task}) async {
    if (debugMode) print('FirestoreAPI: deleteTask called for ${task.taskId}');

    ///Removing all applications from the task
    await _taskCollectionRef
        .document(task.taskId)
        .collection(applicantCollectionName)
        .getDocuments()
        .then((snapshot) async {
      if (snapshot.documents.isNotEmpty)
        for (DocumentSnapshot doc in snapshot.documents) {
          TaskApplicant taskApplicant = TaskApplicant.fromMap(doc.data);
          await removeTaskApplicant(
              providerId: taskApplicant.pid,
              taskId: taskApplicant.taskid,
              applicationId: taskApplicant.applicationId);
        }
    });

    if (debugMode)
      print(
          'FirestoreAPI: deleteTask removing task from hirer ${task.hirerId}');
    await _usersCollectionRef.document(task.hirerId).setData({
      'posts': FieldValue.arrayRemove([task.taskId])
    }, merge: true);

    await _taskCollectionRef.document(task.taskId).delete();
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
      ProviderUser provider = await getProviderById(pid);

      ///Check that the provider exists
      if (provider != null) {
        providers.add(provider);
      }
    }
    return providers;
  }

  Future<List<Task>> getTasks({List postIds}) async {
    if (debugMode) print('FirestoreAPI: getTasks called for $postIds');
    List<Task> tasks = [];
    for (var taskId in postIds) {
      Task task = await getTaskById(taskId: taskId);

      ///Check that the task exists
      if (task != null) {
        tasks.add(task);
      }
    }
    tasks.sort((a, b) => b.time.compareTo(a.time));
    return tasks;
  }

  Future<List<Map<String, dynamic>>> getUserTasksAndNotifications(
      {List postIds}) async {
    if (debugMode)
      print('FirestoreAPI: getUserTasksAndNotifications called for $postIds');

    ///Get the tasks, check that all the task applicants have no "hirerHasUnreadMessage" bool
    /// return as a list of maps

    List<Map<String, dynamic>> tasksAndNotifications = [];

    List<Task> allTasks = await getTasks(postIds: postIds);

    for (Task task in allTasks) {
      Map<String, dynamic> taskAndNotification = {};
      taskAndNotification['task'] = task;

      bool hasNotification =
          await hirerTaskHasNotification(taskId: task.taskId);

      taskAndNotification['hasNotification'] = hasNotification;

      tasksAndNotifications.add(taskAndNotification);
    }

    return tasksAndNotifications;
  }

  Future<List<Map<String, dynamic>>> getProviderTasksAndHirersAndNotifications(
      {List pids}) async {
    ///This function takes a list pids and gets the tasks applied for by each provider

    if (debugMode) print('FirestoreAPI: getProviderTasks called for $pids');

    List<Map<String, dynamic>> tasksAndHirersAndNotifications = [];

    List<ProviderUser> providers = await getProviders(pids: pids);

    for (ProviderUser provider in providers) {
      List<Task> providerTasks = [];

      ///Get tasks the provider has applied to
      providerTasks.addAll(await getTasks(postIds: provider.tasksApplied));

      ///get the hirer associated with each task
      for (Task task in providerTasks) {
        Map<String, dynamic> taskAndHirerAndNotification = {};
        taskAndHirerAndNotification['task'] = task;

        ///Still going to add the provider in, it may be useful in the future
        taskAndHirerAndNotification['provider'] = provider;

        bool hasNotification = await providerApplicationHasNotification(
            taskId: task.taskId, pid: provider.pid);
        taskAndHirerAndNotification['hasNotification'] = hasNotification;

        User hirer = await getUserById(task.hirerId);

        ///Check that the hirer exists before adding to list
        if (hirer != null) {
          taskAndHirerAndNotification['hirer'] = hirer;
          tasksAndHirersAndNotifications.add(taskAndHirerAndNotification);
        }
      }
    }

    tasksAndHirersAndNotifications.sort((a, b) {
      Task taskA = a['task'];
      Task taskB = b['task'];
      return taskB.time.compareTo(taskA.time);
    });

    return tasksAndHirersAndNotifications;
  }

  Future<void> deleteProvider({ProviderUser provider}) async {
    if (debugMode)
      print('FirestoreAPI: deleteProvider called on ${provider.pid}');

    if (provider.chats.isNotEmpty)
      for (String chatID in provider.chats) {
        if (debugMode)
          print('FirestoreAPI: deleteProvider Deleting chat $chatID}');
        Chat chat = await getChatById(chatID);

        ///Check that the chat exists before deleting
        if (chat != null) await deleteChat(chat: chat);
      }

    ///Remove provider from any hirer favourites
    if (provider.isFavouritedBy.isNotEmpty)
      for (String uid in provider.isFavouritedBy) {
        if (debugMode)
          print(
              'FirestoreAPI: deleteProvider Removing provider from hirer: $uid favourites');
        await removeUserFavourite(uid: uid, favouritePid: provider.pid);
      }

    ///Remove provider from tasks they have applied to
    if (provider.tasksApplied.isNotEmpty)
      for (String taskId in provider.tasksApplied) {
        if (debugMode)
          print(
              'FirestoreAPI: deleteProvider Removing provider application from task $taskId');

        Task appliedTask = await getTaskById(taskId: taskId);

        ///Check that the applied task exists
        if (appliedTask != null) {
          ///Find the application corresponding to this provider.pid
          QuerySnapshot applications = await _taskCollectionRef
              .document(taskId)
              .collection(applicantCollectionName)
              .where('pid', isEqualTo: provider.pid)
              .getDocuments();
          if (applications.documents.isNotEmpty)
            for (DocumentSnapshot doc in applications.documents) {
              await removeTaskApplicant(
                  providerId: provider.pid,
                  taskId: taskId,
                  applicationId: doc.documentID);
            }
        }
      }

    ///Delete the provider
    await _providersCollectionRef.document(provider.pid).delete();

    ///Remove provider from user's array
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

  Future<void> deleteDisplayPicture({User user}) async {
    await FirebaseStorage.instance
        .ref()
        .child(user.displayPictureFileName)
        .delete();
    await _usersCollectionRef.document(user.id).setData({
      'displayPictureFileName': FieldValue.delete(),
      'displayPictureURL': FieldValue.delete()
    }, merge: true);
    if (user.providerProfiles.isNotEmpty)
      for (String pid in user.providerProfiles) {
        await _providersCollectionRef.document(pid).setData({
          'displayPictureFileName': FieldValue.delete(),
          'displayPictureURL': FieldValue.delete()
        }, merge: true);
      }
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
