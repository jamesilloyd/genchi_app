import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/main.dart';
import '../models/user.dart';
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
  static CollectionReference _usersCollectionRef =
  Firestore.instance.collection('development/sSqkhUUghSa8kFVLE05Z/users');

  static CollectionReference _chatCollectionRef =
  Firestore.instance.collection('development/sSqkhUUghSa8kFVLE05Z/chats');

  static CollectionReference _taskCollectionRef =
  Firestore.instance.collection('development/sSqkhUUghSa8kFVLE05Z/tasks');

  static CollectionReference _providerCollectionRef = Firestore.instance
      .collection('development/sSqkhUUghSa8kFVLE05Z/providers');

  static CollectionReference _developmentCollectionRef =
  Firestore.instance.collection('development');

  ///***------------------ SERVICE SEARCH FUNCTIONS ------------------***

  Future<List<User>> fetchServiceProviders() async {
    List<User> serviceProviders;
    var result = await _usersCollectionRef
        .where('accountType', isEqualTo: 'Service Provider')
        .getDocuments();
    serviceProviders =
        result.documents.map((doc) => User.fromMap(doc.data)).toList();
    return serviceProviders;
  }

  Future<List<User>> getUsersByAccountType({String accountType}) async {
    if (debugMode) print(
        'FirestoreAPI: getUsersByAccountType called for $accountType');
    List<User> users = [];

    QuerySnapshot result = await _usersCollectionRef.where(
        'accountType', isEqualTo: accountType).orderBy('name').
    getDocuments();

    users = result.documents.map((doc) => User.fromMap(doc.data)).toList();

    return users;
  }

  Future<List<User>> getProvidersByService({String serviceType}) async {
    QuerySnapshot result = await _usersCollectionRef
        .where('accountType', isEqualTo: 'Service Provider')
        .where('category', isEqualTo: serviceType)
        .getDocuments();
    List<User> allServiceProviders =
    result.documents.map((doc) => User.fromMap(doc.data)).toList();
    return allServiceProviders;
  }

  Future<DocumentReference> addServiceProvider(
      {User serviceUser, String uid}) async {
    DocumentReference result = await _usersCollectionRef
        .add(serviceUser.toJson())
        .then((docRef) async {
      await updateUser(
        user: User(id: docRef.documentID),
        uid: docRef.documentID,
      );

      ///add to main user's profile as well
      await _usersCollectionRef.document(uid).updateData({
        'providerProfiles': FieldValue.arrayUnion([docRef.documentID])
      });
      return docRef;
    });

    return result;
  }

  Future<List<User>> getServiceProviders({List ids}) async {
    if (debugMode) print('FirestoreAPI: getServiceProviders called for $ids');
    List<User> serviceProviders = [];
    for (var id in ids) {
      User serviceProvider = await getUserById(id);

      ///Check that the provider exists
      if (serviceProvider != null) {
        serviceProviders.add(serviceProvider);
      }
    }
    return serviceProviders;
  }

  //TODO: what else is required to delete a normal user account tied to an email?
  Future<void> deleteServiceProvider({User serviceProvider}) async {
    if (debugMode)
      print(
          'FirestoreAPI: deleteSerivceProvider called on ${serviceProvider
              .id}');

    ///Delete chats
    if (serviceProvider.chats.isNotEmpty)
      for (String chatID in serviceProvider.chats) {
        if (debugMode)
          print('FirestoreAPI: deleteServiceProvider: Deleting chat $chatID}');
        Chat chat = await getChatById(chatID);

        ///Check that the chat exists before deleting
        if (chat != null) await deleteChat(chat: chat);
      }

    ///Remove provider from any hirer favourites
    if (serviceProvider.isFavouritedBy.isNotEmpty)
      for (String uid in serviceProvider.isFavouritedBy) {
        if (debugMode)
          print(
              'FirestoreAPI: deleteServiceProvider Removing provider from hirer: $uid favourites');
        await removeUserFavourite(uid: uid, favouriteId: serviceProvider.id);
      }

    ///Remove provider from tasks they have applied to
    if (serviceProvider.tasksApplied.isNotEmpty)
      for (String taskId in serviceProvider.tasksApplied) {
        if (debugMode)
          print(
              'FirestoreAPI: deleteServiceProvider Removing application from task $taskId');

        ///Find the application corresponding to this provider.id
        QuerySnapshot applications = await _taskCollectionRef
            .document(taskId)
            .collection(applicantCollectionName)
            .where('applicantId', isEqualTo: serviceProvider.id)
            .getDocuments();

        if (applications.documents.isNotEmpty)
          for (DocumentSnapshot doc in applications.documents) {
            await removeTaskApplicant(
                applicantId: serviceProvider.id,
                taskId: taskId,
                applicationId: doc.documentID);
          }
      }

    ///Delete the provider
    await _usersCollectionRef.document(serviceProvider.id).delete();

    ///Remove provider from user's array
    await _usersCollectionRef
        .document(serviceProvider.mainAccountId)
        .updateData({
      'providerProfiles': FieldValue.arrayRemove([serviceProvider.id])
    });
    if (debugMode) print('FirestoreAPI: deleteServiceProvider complete');
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

  Future<List<User>> getUsersFavourites(userFavourites) async {
    List<User> favUsers = [];
    if (debugMode)
      print(
          'FirestoreAPIService: getUserFavourites called on: $userFavourites');
    for (var id in userFavourites) {
      User favUser = await getUserById(id);

      ///Check that the service provider exists
      if (favUser != null) {
        favUsers.add(favUser);
      }
    }
    favUsers.sort((a, b) => a.category.compareTo(b.category));
    return favUsers;
  }


  Future removeUserFavourite({String uid, String favouriteId}) async {
    if (debugMode)
      print(
          'FirestoreAPI: removeUserFavourite called for user $uid favouriting user $favouriteId');
    await _usersCollectionRef.document(uid).updateData({
      'favourites': FieldValue.arrayRemove([favouriteId])
    });
    await _usersCollectionRef.document(favouriteId).updateData({
      'isFavouritedBy': FieldValue.arrayRemove([uid])
    });
  }

  Future addUserFavourite({String uid, String favouriteId}) async {
    if (debugMode)
      print(
          'FirestoreAPI: addUserFavourite called for user $uid unfavouriting user $favouriteId');
    await _usersCollectionRef.document(uid).updateData({
      'favourites': FieldValue.arrayUnion([favouriteId])
    });
    await _usersCollectionRef.document(favouriteId).updateData({
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

    ///Repeat for users service provider profiles
    if (user.providerProfiles.isNotEmpty)
      for (String id in user.providerProfiles) {
        await _usersCollectionRef.document(id).updateData({
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
    if (debugMode) print(
        'firestoreApi: streamUserChats called on ${user.id} and ${user
            .providerProfiles}');

    ///Getting all the chats associated with main account
    Stream stream1 = _chatCollectionRef
        .where('ids', arrayContains: user.id)
        .orderBy('time', descending: true)
        .snapshots()
        .asyncMap((event) async {
      var futures = event.documents.map((doc) async {
        Chat chat = Chat.fromMap(doc.data);

        ///Check if user is id1 or id2
        bool isUser1 = user.id == chat.id1;

        ///Get other user's profile
        User otherUser = await getUserById(isUser1 ? chat.id2 : chat.id1);

        if (otherUser != null) {
          return {
            'chat': chat,
            'otherUser': otherUser,
            'user': user,
            'userIsUser1': isUser1,
          };
        } else
          return null;
      });

      return await Future.wait(futures);
    });

    ///Grabbing chats associated with provider profiles
    if (user.providerProfiles.isNotEmpty) {
      //TODO HOW DO WE QUERY THIS??? TODO HOW DO WE QUERY THIS??? TODO HOW DO WE QUERY THIS??? TODO HOW DO WE QUERY THIS??? TODO HOW DO WE QUERY THIS??? TODO HOW DO WE QUERY THIS???
      Stream stream2 = _chatCollectionRef
          .where('ids', arrayContainsAny: user.providerProfiles)
          .orderBy('time', descending: true)
          .snapshots()
          .asyncMap((event) async {
        var futures = event.documents.map((doc) async {
          Chat chat = Chat.fromMap(doc.data);

          ///Work out if the user's service provider is id1 or id2
          bool isUser1 = user.providerProfiles.contains(chat.id1);

          User serviceProvider =
          await getUserById(isUser1 ? chat.id1 : chat.id2);
          User otherUser = await getUserById(isUser1 ? chat.id2 : chat.id1);

          if (serviceProvider != null && otherUser != null) {
            return {
              'chat': chat,
              'otherUser': otherUser,
              'user': serviceProvider,
              'userIsUser1': isUser1
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

  Future addMessageToChat(
      {String chatId, ChatMessage chatMessage, bool senderIsUser1}) async {
    Chat chat = Chat(
        lastMessage: chatMessage.text,
        time: chatMessage.time,
        isHiddenFromUser1: false,
        isHiddenFromUser2: false);

    senderIsUser1
        ? chat.user2HasUnreadMessage = true
        : chat.user1HasUnreadMessage = true;

    await _chatCollectionRef.document(chatId).updateData(chat.toJson());

    var result = await _chatCollectionRef
        .document(chatId)
        .collection('messages')
        .add(chatMessage.toJson());

    return result;
  }

  Future<DocumentReference> addNewChat(
      {String initiatorId, String recipientId}) async {
    ///Message sender is the id1, recipient is id2
    Chat chat = Chat(
        ids: [initiatorId, recipientId],
        id1: initiatorId,
        id2: recipientId,
        isHiddenFromUser2: false,
        isHiddenFromUser1: false);

    DocumentReference result =
    await _chatCollectionRef.add(chat.toJson()).then((docRef) async {
      await updateChat(chat: Chat(chatid: docRef.documentID));

      ///Add to senders array
      await _usersCollectionRef.document(initiatorId).updateData({
        'chats': FieldValue.arrayUnion([docRef.documentID])
      });

      ///add to recipient's array
      await _usersCollectionRef.document(recipientId).updateData({
        'chats': FieldValue.arrayUnion([docRef.documentID])
      });
      return docRef;
    });

    return result;
  }

  Future<void> deleteChat({Chat chat}) async {
    ///Deleting chat from users's arrays
    await _usersCollectionRef.document(chat.id1).updateData({
      'chats': FieldValue.arrayRemove([chat.chatid])
    });

    await _usersCollectionRef.document(chat.id2).updateData({
      'chats': FieldValue.arrayRemove([chat.chatid])
    });

    ///Deleting messages attached to the chat
    await _chatCollectionRef
        .document(chat.chatid)
        .collection('messages')
        .getDocuments()
        .then((snapshot) async {
      if (snapshot.documents.isNotEmpty)
        for (DocumentSnapshot doc in snapshot.documents) {
          await doc.reference.delete();
        }
    });

    ///Deleting the chat
    await _chatCollectionRef.document(chat.chatid).delete();
  }

  Future<void> hideChat({Chat chat, String hiddenId}) async {
    if (debugMode) print('FirestoreAPI: hideChat called');

    ///work out to hide it from user 1 or user 2
    bool hideForUser1 = hiddenId == chat.id1;

    hideForUser1
        ? chat.isHiddenFromUser1 = true
        : chat.isHiddenFromUser2 = true;

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
      {@required Task task, @required String hirerId}) async {
    DocumentReference result =
    await _taskCollectionRef.add(task.toJson()).then((docRef) async {
      await updateTask(
        task: Task(taskId: docRef.documentID),
        taskId: docRef.documentID,
      );
      await _usersCollectionRef.document(hirerId).updateData({
        'posts': FieldValue.arrayUnion([docRef.documentID])
      });
      return docRef;
    });

    return result;
  }

  Future updateTaskApplication({TaskApplication taskApplication}) async {
    await _taskCollectionRef
        .document(taskApplication.taskid)
        .collection(applicantCollectionName)
        .document(taskApplication.applicationId)
        .updateData(taskApplication.toJson());
  }

  Future<List<Map<String, dynamic>>> fetchTasksAndHirers() async {
    ///This function is for fetching all the tasks for the tasks feed

    if (debugMode) print('FirestoreAPI: fetchTasksAndHirers called');

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
      {@required String taskid, @required String applicationId}) {
    return _taskCollectionRef
        .document(taskid)
        .collection(applicantCollectionName)
        .document(applicationId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future getTaskApplicationById({String taskId, String applicationId}) async {
    DocumentSnapshot doc = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicationId)
        .get();

    return doc.exists ? TaskApplication.fromMap(doc.data) : null;
  }

  Future<bool> providerApplicationHasNotification(
      {@required String taskId, @required String applicantId}) async {
    bool hasNotification = false;

    ///Don't need to worry too much about this document not existing as
    ///it is only called for the tasks that the provider has applied to
    QuerySnapshot docs = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .where('applicantId', isEqualTo: applicantId)
        .getDocuments();

    if (docs.documents.isNotEmpty)
      for (DocumentSnapshot doc in docs.documents) {
        TaskApplication taskApplication = TaskApplication.fromMap(doc.data);

        ///If the taskapplicant has an unread messages then mark the notification as true
        if (taskApplication.applicantHasUnreadMessage) hasNotification = true;
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
        TaskApplication taskApplication = TaskApplication.fromMap(doc.data);

        ///If the hirer has an unread messages then mark has notification as true
        if (taskApplication.hirerHasUnreadMessage) hasNotification = true;
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
      List<TaskApplication> tasksApplicants = applicants.documents
          .map((doc) => TaskApplication.fromMap(doc.data))
          .toList();

      for (TaskApplication application in tasksApplicants) {
        Map<String, dynamic> applicationAndProvider = {};

        if (debugMode)
          print(
              'FirestoreAPI: getTaskChatsAndProviders found application ${application
                  .applicationId} and applicant ${application.applicantId}');

        ///Grab the applicant associated with the application
        User applicant = await getUserById(application.applicantId);

        ///Check that the applicant exists
        if (applicant != null) {
          applicationAndProvider['application'] = application;
          applicationAndProvider['applicant'] = applicant;
          applicationAndProviders.add(applicationAndProvider);
        }
      }

      applicationAndProviders.sort((a, b) {
        TaskApplication taskA = a['application'];
        TaskApplication taskB = b['application'];
        return taskB.time.compareTo(taskA.time);
      });
    }

    return applicationAndProviders;
  }

  Future addMessageToTaskApplicant({@required String applicationId,
    @required ChatMessage chatMessage,
    @required bool applicantIsSender,
    @required String taskId}) async {
    TaskApplication taskApplication = TaskApplication(
        lastMessage: chatMessage.text,
        time: chatMessage.time,
        isHiddenFromApplicant: false,
        isHiddenFromHirer: false);

    applicantIsSender
        ? taskApplication.hirerHasUnreadMessage = true
        : taskApplication.applicantHasUnreadMessage = true;

    ///Update the taskApplicant data
    await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicationId)
        .updateData(taskApplication.toJson());

    ///Add the message to the task applicant collection
    var result = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .document(applicationId)
        .collection('messages')
        .add(chatMessage.toJson());

    return result;
  }

  Future<DocumentReference> applyToTask({@required String taskId,
    @required String applicantId,
    @required String hirerId}) async {
    if (debugMode)
      print(
          'FirestoreAPI: applyToTask called for task $taskId by applicant $applicantId');

    TaskApplication taskApplication = TaskApplication(
        taskid: taskId,
        hirerid: hirerId,
        applicantId: applicantId,
        isHiddenFromHirer: false,
        isHiddenFromApplicant: false);

    ///Add applicant to task collection
    DocumentReference taskApplicationResult = await _taskCollectionRef
        .document(taskId)
        .collection(applicantCollectionName)
        .add(taskApplication.toJson())
        .then((docRef) async {
      await updateTaskApplication(
          taskApplication: TaskApplication(
              applicationId: docRef.documentID, taskid: taskId));
      return docRef;
    });

    ///Add application to users tasksApplied
    await _usersCollectionRef.document(applicantId).updateData({
      'tasksApplied': FieldValue.arrayUnion([taskId])
    });

    return taskApplicationResult;
  }

  Future removeTaskApplicant({
    @required String applicantId,
    @required String taskId,
    @required String applicationId,
  }) async {
    if (debugMode)
      print(
          'FirestoreAPI: removeTaskApplicant called for task $taskId on applicant $applicantId');

    ///Remove from applicant's array
    await _usersCollectionRef.document(applicantId).updateData({
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
      if (snapshot.documents.isNotEmpty) {
        for (DocumentSnapshot doc in snapshot.documents) {
          TaskApplication taskApplication = TaskApplication.fromMap(doc.data);

          await removeTaskApplicant(
              applicantId: taskApplication.applicantId,
              taskId: taskApplication.taskid,
              applicationId: taskApplication.applicationId);
        }
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

  Future<List<Map<String, dynamic>>> getUserTasksPostedAndNotifications(
      {List postIds}) async {
    if (debugMode)
      print(
          'FirestoreAPI: getUserTasksPostedAndNotifications called for $postIds');

    ///Get the tasks, check that all the task applicants for "hirerHasUnreadMessage" bool
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

  Future<List<Map<String, dynamic>>> getUserTasksAppliedAndNotifications(
      {List providerIds, String mainId}) async {
    ///This function takes a list ids and gets the tasks applied for by each id

    if (debugMode)
      print(
          'FirestoreAPI: getUserTasksAppliedAndNotifications called for $providerIds and $mainId');

    List allIds = [];
    allIds.addAll(providerIds);
    allIds.add(mainId);

    List<Task> appliedTasks = [];

    List<Map<String, dynamic>> tasksAndHirersAndNotifications = [];


    ///THEN FIND ALL THE TASKS APPLIED ASSOCIATED WITH THE PROVIDER IDS
    for (String id in allIds) {
      ///Empty the task collector
      appliedTasks.clear();

      User applicant = await getUserById(id);

      ///Get tasks the id has applied to
      if (applicant.tasksApplied.isNotEmpty) {
        appliedTasks.addAll(await getTasks(postIds: applicant.tasksApplied));

        ///get the hirer associated with each task
        for (Task task in appliedTasks) {
          Map<String, dynamic> taskAndHirerAndNotification = {};
          taskAndHirerAndNotification['task'] = task;

          bool hasNotification = await providerApplicationHasNotification(
              taskId: task.taskId, applicantId: applicant.id);

          taskAndHirerAndNotification['hasNotification'] = hasNotification;

          User hirer = await getUserById(task.hirerId);

          ///Check that the hirer exists before adding to list
          if (hirer != null) {
            taskAndHirerAndNotification['hirer'] = hirer;
            tasksAndHirersAndNotifications.add(taskAndHirerAndNotification);
          }
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

  Future addFCMToken({@required User user, @required String token}) async {
    ///Update in the main user's account
    await _usersCollectionRef.document(user.id).updateData({
      'fcmTokens': FieldValue.arrayUnion([token])
    });

    ///Add to any provider profiles they own
    if (user.providerProfiles.isNotEmpty)
      for (String pid in user.providerProfiles) {
        await _usersCollectionRef.document(pid).updateData({
          'fcmTokens': FieldValue.arrayUnion([token])
        });
      }
  }

  Future migrateToNewDatabaseArchitecture() async {
    print('started migrateToNewDatabaseArchitecture');

    ///Update all user fields
    await _usersCollectionRef.getDocuments().then((value) async {
      for (DocumentSnapshot userData in value.documents) {
        User user = User.fromMap(userData.data);
        await _usersCollectionRef.document(user.id).updateData(user.toJson());
      }
    });

    ///need to move all providers into users collection and update fields
    await _providerCollectionRef.getDocuments().then((value) async {
      for (DocumentSnapshot providerData in value.documents) {
        User serviceProvider = User.fromMap(providerData.data);
        serviceProvider.accountType = 'Service Provider';
        await _usersCollectionRef
            .document(serviceProvider.id)
            .setData(serviceProvider.toJson(), merge: true);
      }
    });

    ///Update all chats
    await _chatCollectionRef.getDocuments().then((value) async {
      for (DocumentSnapshot chatData in value.documents) {
        Chat chat = Chat.fromMap(chatData.data);
        chat.ids = [chat.id1,chat.id2];
        await _chatCollectionRef
            .document(chat.chatid)
            .updateData(chat.toJson());
      }
    });

    ///Update all tasks and taskApplications
    await _taskCollectionRef.getDocuments().then((value1) async {
      for (DocumentSnapshot doc1 in value1.documents) {
        ///Update the task document
        Task task = Task.fromMap(doc1.data);
        await _taskCollectionRef
            .document(task.taskId)
            .updateData(task.toJson());

        ///Update the task application documents
        await _taskCollectionRef
            .document(task.taskId)
            .collection(applicantCollectionName)
            .getDocuments()
            .then((value2) async {
          for (DocumentSnapshot doc2 in value2.documents) {
            TaskApplication taskApplication =
            TaskApplication.fromMap(doc2.data);
            await _taskCollectionRef
                .document(task.taskId)
                .collection(applicantCollectionName)
                .document(taskApplication.applicationId)
                .updateData(taskApplication.toJson());
          }
        });
      }
    });

    print('finished migrateToNewDatabaseArchitecture');
  }

  ///Must only call this whilst in PRODUCTION MODE
  Future createDevEnvironment() async {
    ///grab all data from firestore
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

    //TODO: after transfer this isn't required
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
