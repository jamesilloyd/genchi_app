import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/provider.dart';
import '../models/chat.dart';
import 'package:genchi_app/models/task.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:genchi_app/constants.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreAPIService {

  ///PRODUCTION MODE
//  CollectionReference _usersCollectionRef =
//  Firestore.instance.collection('users');

//  CollectionReference _providersCollectionRef =
//  Firestore.instance.collection('providers');

//  CollectionReference _chatCollectionRef =
//  Firestore.instance.collection('chats');

//  CollectionReference _taskCollectionRef =
//  Firestore.instance.collection('tasks');


  ///DEVELOP MODE
  static CollectionReference _usersCollectionRef = Firestore.instance
      .collection('development/sSqkhUUghSa8kFVLE05Z/users');

  static CollectionReference _providersCollectionRef = Firestore.instance
      .collection('development/sSqkhUUghSa8kFVLE05Z/providers');

  static CollectionReference _chatCollectionRef = Firestore.instance
      .collection('development/sSqkhUUghSa8kFVLE05Z/chats');

  static CollectionReference _taskCollectionRef = Firestore.instance
      .collection('development/sSqkhUUghSa8kFVLE05Z/tasks');

  static CollectionReference _developmentCollectionRef =
  Firestore.instance.collection('development');


  ///***------------------ PROVIDER FUNCTIONS ------------------***


  Future getProviderById(String pid) async {
    DocumentSnapshot doc = await _providersCollectionRef.document(pid).get();
    return doc.exists ? ProviderUser.fromMap(doc.data) : null;
  }

  Future updateProvider({ProviderUser provider, String pid}) async {
    await _providersCollectionRef.document(pid).updateData(provider.toJson());
    return;
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


  Future<DocumentReference> addProvider(
      ProviderUser provider, String uid) async {
    DocumentReference result = await _providersCollectionRef
        .add(provider.toJson())
        .then((docRef) async {
      await updateProvider(
        provider: ProviderUser(pid: docRef.documentID),
        pid: docRef.documentID,
      );
      await _usersCollectionRef.document(uid).updateData({
        'providerProfiles': FieldValue.arrayUnion([docRef.documentID])
      });
      return docRef;
    });

    return result;
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
    await _usersCollectionRef.document(provider.uid).updateData({
      'providerProfiles': FieldValue.arrayRemove([provider.pid])
    });
    if (debugMode) print('FirestoreAPI: deleteProvider complete');
  }

  ///***------------------ USER FUNCTIONS ------------------***


  Future getUserById(String uid) async {
    var doc = await _usersCollectionRef.document(uid).get();
    return doc.exists ? User.fromMap(doc.data) : null;
  }


  Future updateUser({User user, String uid}) async {
    await _usersCollectionRef.document(uid).updateData(user.toJson());
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

  Future removeUserFavourite(
      {String uid, String favouritePid}) async {
    if (debugMode)
      print(
          'FirestoreAPI: removeUserFavourite called for hirer $uid on provider $favouritePid');
    await _usersCollectionRef.document(uid).updateData({
      'favourites': FieldValue.arrayRemove([favouritePid])
    });
    await _providersCollectionRef.document(favouritePid).updateData({
      'isFavouritedBy': FieldValue.arrayRemove([uid])
    });
  }

  Future addUserFavourite(
      {String uid, String favouritePid}) async {
    if (debugMode)
      print(
          'FirestoreAPI: addUserFavourite called for hirer $uid on provider $favouritePid');
    await _usersCollectionRef.document(uid).updateData({
      'favourites': FieldValue.arrayUnion([favouritePid])
    });
    await _providersCollectionRef.document(favouritePid).updateData({
      'isFavouritedBy': FieldValue.arrayUnion([uid])
    });
  }


  Future<void> deleteDisplayPicture({User user}) async {
    await FirebaseStorage.instance
        .ref()
        .child(user.displayPictureFileName)
        .delete();
    await _usersCollectionRef.document(user.id).updateData({
      'displayPictureFileName': FieldValue.delete(),
      'displayPictureURL': FieldValue.delete()
    });

    if (user.providerProfiles.isNotEmpty)
      for (String pid in user.providerProfiles) {
        await _providersCollectionRef.document(pid).updateData({
          'displayPictureFileName': FieldValue.delete(),
          'displayPictureURL': FieldValue.delete()
        });
      }
  }


  ///***------------------ CHAT FUNCTIONS ------------------***



  Stream<QuerySnapshot> fetchChatStream(String chatId) {
    return _chatCollectionRef
        .document(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }


  Future getChatById(String chatId) async {
    var doc = await _chatCollectionRef.document(chatId).get();
    return doc.exists ? Chat.fromMap(doc.data) : null;
  }

  Future updateChat({Chat chat}) async {
    await _chatCollectionRef.document(chat.chatid).updateData(chat.toJson());
  }



  Stream streamUserChats({User user}) {
    ///This function is used to stream all the private chats a user has (and their provider chats)
    if (debugMode) print('firestoreApi: streamUserChats called on ${user.id}');

    ///Getting all the chats
    Stream stream1 = _chatCollectionRef
        .where('uid', isEqualTo: user.id)
        .orderBy('time', descending: true)
        .snapshots()
        .asyncMap((event) async {
      //TODO look to see if we can just call getproviderbyid on the docs that have changed (while still caching old docs)
      //TODO also, rather than calling getProviderById on every one, we could create a list of all pids and call in one go?

      var futures = event.documents.map((doc) async {
        Chat chat = Chat.fromMap(doc.data);

        ///Check if that chat is for hiring or providing

        ///Chat is for hiring
        ///Get providers profile
        ProviderUser provider = await getProviderById(chat.pid);

        if (provider != null) {
          return {
            'chat': chat,
            'provider': provider,
            'hirer': user,
            'userIsProvider': false
          };
        } else
          return null;
      });

      return await Future.wait(futures);
    });

    if (user.providerProfiles.isNotEmpty) {
      Stream stream2 = _chatCollectionRef
          .where('pid', whereIn: user.providerProfiles)
          .orderBy('time', descending: true)
          .snapshots()
          .asyncMap((event) async {
        //TODO look to see if we can just call getproviderbyid on the docs that have changed (while still chaching old docs)
        var futures = event.documents.map((doc) async {
          Chat chat = Chat.fromMap(doc.data);
          ProviderUser provider = await getProviderById(chat.pid);
          User hirer = await getUserById(chat.uid);

          if (provider != null && hirer != null) {
            return {
              'chat': chat,
              'provider': provider,
              'hirer': hirer,
              'userIsProvider': true
            };
          } else
            return null;
        });

        return await Future.wait(futures);
      });

      return Rx.combineLatest([stream1, stream2], (values) => values);
    } else {
      return stream1;
    }
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

    await _chatCollectionRef.document(chatId).updateData(chat.toJson());

    var result = await _chatCollectionRef
        .document(chatId)
        .collection('messages')
        .add(chatMessage.toJson());

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
      await _usersCollectionRef.document(uid).updateData({
        'chats': FieldValue.arrayUnion([docRef.documentID])
      });

      await _providersCollectionRef.document(pid).updateData({
        'chats': FieldValue.arrayUnion([docRef.documentID])
      });
      return docRef;
    });

    return result;
  }

  Future<void> deleteChat({Chat chat}) async {
    ///Deleting chat from provider's array
    await _providersCollectionRef.document(chat.pid).updateData({
      'chats': FieldValue.arrayRemove([chat.chatid])
    });

    ///Deleting chat from hirer's array
    await _usersCollectionRef.document(chat.uid).updateData({
      'chats': FieldValue.arrayRemove([chat.chatid])
    });

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


  Future<void> hideChat({Chat chat, bool forProvider}) async {
    if (debugMode) print('FirestoreAPI: hideChat called');
    forProvider
        ? chat.isHiddenFromProvider = true
        : chat.isHiddenFromUser = true;
    print(chat.isHiddenFromUser);
    print(chat.isHiddenFromProvider);
    await updateChat(chat: chat);
  }


  ///***------------------ TASK FUNCTIONS ------------------***

  final String applicantCollectionName = 'applicants';

  Future getTaskById({String taskId}) async {
    DocumentSnapshot doc = await _taskCollectionRef.document(taskId).get();
    return doc.exists ? Task.fromMap(doc.data) : null;
  }

  Future updateTask({Task task, String taskId}) async {
    await _taskCollectionRef.document(taskId).updateData(task.toJson());
    return;
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
      await _usersCollectionRef.document(uid).updateData({
        'posts': FieldValue.arrayUnion([docRef.documentID])
      });
      return docRef;
    });

    return result;
  }

  Future updateTaskApplicant({TaskApplicant taskApplicant}) async {
    await _taskCollectionRef
        .document(taskApplicant.taskid)
        .collection(applicantCollectionName)
        .document(taskApplicant.applicationId)
        .updateData(taskApplicant.toJson());
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



  Future<List<Map<String, dynamic>>> fetchTasksAndHirersByService(
      {String service}) async {
    if (debugMode)
      print(
          'FirestoreAPI: fetchTasksAndHirersByService called on service $service');

    ///This function is for fetching all the tasks for the tasks feed

    List<Map<String, dynamic>> tasksAndHirers = [];
    List<Task> tasks;
    var result = await _taskCollectionRef
        .where('service', isEqualTo: service)
        .getDocuments();

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
              'FirestoreAPI: getTaskChatsAndProviders found application ${applicant.applicationId} and applicant ${applicant.applicantid}');

        ///Grab the provider associated with the application
        ProviderUser provider = await getProviderById(applicant.applicantid);

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



  Future addMessageToTaskApplicant(
      {@required String applicantId,
        @required ChatMessage chatMessage,
        @required bool applicantIsSender,
        @required String taskId}) async {
    TaskApplicant taskApplicant = TaskApplicant(
        lastMessage: chatMessage.text,
        time: chatMessage.time,
        isHiddenFromProvider: false,
        isHiddenFromHirer: false);

    applicantIsSender
        ? taskApplicant.hirerHasUnreadMessage = true
        : taskApplicant.providerHasUnreadMessage = true;

    ///Update the taskApplicant data
    await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicantId)
        .updateData(taskApplicant.toJson());

    ///Add the message to the task applicant collection
    var result = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicantId)
        .collection('messages')
        .add(chatMessage.toJson());

    return result;
  }


  Future<DocumentReference> applyToTask(
      {@required String taskId,
        @required String applicantId,
        @required bool applicantIsUser,
        @required String userId}) async {
    if (debugMode)
      print(
          'FirestoreAPI: applyToTask called for task $taskId by applicant $applicantId');

    TaskApplicant taskApplicant = TaskApplicant(
        taskid: taskId,
        hirerid: userId,
        applicantid: applicantId,
        applicantIsUser: applicantIsUser,
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

    ///Add applicant to provider / users tasksApplied
    if(applicantIsUser) {
      await _usersCollectionRef.document(applicantId).updateData({
        'tasksApplied': FieldValue.arrayUnion([taskId])
      });

    } else {
      await _providersCollectionRef.document(applicantId).updateData({
        'tasksApplied': FieldValue.arrayUnion([taskId])
      });
    }
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
    await _providersCollectionRef.document(providerId).updateData({
      'tasksApplied': FieldValue.arrayRemove([taskId])
    });

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
              providerId: taskApplicant.applicantid,
              taskId: taskApplicant.taskid,
              applicationId: taskApplicant.applicationId);
        }
    });

    if (debugMode)
      print(
          'FirestoreAPI: deleteTask removing task from hirer ${task.hirerId}');
    await _usersCollectionRef.document(task.hirerId).updateData({
      'posts': FieldValue.arrayRemove([task.taskId])
    });

    await _taskCollectionRef.document(task.taskId).delete();
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
      if (provider.tasksApplied.isNotEmpty)
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



  ///***------------------ OTHER FUNCTIONS ------------------***

  Future createDevEnvironment() async {
    ///grab all data form firestore
    ///send under the development collection

    DocumentReference devDoc =
    await _developmentCollectionRef.add({'timeStamp': Timestamp.now()});

    ///chats
    await Firestore.instance
        .collection('chats')
        .getDocuments()
        .then((value1) async {
      for (DocumentSnapshot doc1 in value1.documents) {
        ///Add to firebase dev collection
        await _developmentCollectionRef
            .document(devDoc.documentID)
            .collection('chats')
            .document(doc1.documentID)
            .setData(doc1.data);

        ///grab sub collection documents for each document
        await Firestore.instance
            .collection('chats')
            .document(doc1.documentID)
            .collection('messages')
            .getDocuments()
            .then((value2) async {
          ///add sub collection documents to dev collection
          for (DocumentSnapshot doc2 in value2.documents) {
            await _developmentCollectionRef
                .document(devDoc.documentID)
                .collection('chats')
                .document(doc1.documentID)
                .collection('messages')
                .document(doc2.documentID)
                .setData(doc2.data);
          }
        });
      }
    });

    ///Users
    await Firestore.instance
        .collection('users')
        .getDocuments()
        .then((value1) async {
      for (DocumentSnapshot doc1 in value1.documents) {
        ///Add to firebase dev collection
        await _developmentCollectionRef
            .document(devDoc.documentID)
            .collection('users')
            .document(doc1.documentID)
            .setData(doc1.data);
      }
    });

    ///Providers
    await Firestore.instance
        .collection('providers')
        .getDocuments()
        .then((value1) async {
      for (DocumentSnapshot doc1 in value1.documents) {
        ///Add to firebase dev collection
        await _developmentCollectionRef
            .document(devDoc.documentID)
            .collection('providers')
            .document(doc1.documentID)
            .setData(doc1.data);
      }
    });

    ///Tasks
    await Firestore.instance
        .collection('tasks')
        .getDocuments()
        .then((value1) async {
      for (DocumentSnapshot doc1 in value1.documents) {
        ///Add to firebase dev collection
        await _developmentCollectionRef
            .document(devDoc.documentID)
            .collection('tasks')
            .document(doc1.documentID)
            .setData(doc1.data);

        ///grab sub collection documents for each document
        await Firestore.instance
            .collection('tasks')
            .document(doc1.documentID)
            .collection('applicants')
            .getDocuments()
            .then((value2) async {
          for (DocumentSnapshot doc2 in value2.documents) {
            ///add sub collection documents to dev collection
            await _developmentCollectionRef
                .document(devDoc.documentID)
                .collection('tasks')
                .document(doc1.documentID)
                .collection('applicants')
                .document(doc2.documentID)
                .setData(doc2.data);

            ///grab sub collection documents for each document
            await Firestore.instance
                .collection('tasks')
                .document(doc1.documentID)
                .collection('applicants')
                .document(doc2.documentID)
                .collection('messages')
                .getDocuments()
                .then((value3) async {
              for (DocumentSnapshot doc3 in value3.documents) {
                ///add sub collection documents to dev collection
                await _developmentCollectionRef
                    .document(devDoc.documentID)
                    .collection('tasks')
                    .document(doc1.documentID)
                    .collection('applicants')
                    .document(doc2.documentID)
                    .collection('messages')
                    .document(doc3.documentID)
                    .setData(doc3.data);
              }
            });
          }
        });
      }
    });
    print('Done');
  }
}
