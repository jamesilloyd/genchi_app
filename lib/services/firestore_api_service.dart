import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/models/feedback.dart';
import '../models/user.dart';
import '../models/chat.dart';
import 'package:genchi_app/models/task.dart';
import 'package:firebase_storage/firebase_storage.dart' hide Task;
import 'package:genchi_app/constants.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreAPIService {
  ///PRODUCTION MODE
  // static CollectionReference _usersCollectionRef =
  //     FirebaseFirestore.instance.collection('users');
  //
  // static CollectionReference _chatCollectionRef =
  //     FirebaseFirestore.instance.collection('chats');
  //
  // static CollectionReference _taskCollectionRef =
  //     FirebaseFirestore.instance.collection('tasks');

  static CollectionReference _feedbackCollectionRef =
      FirebaseFirestore.instance.collection('feedback');

  static CollectionReference _universityCollectionRef =
      FirebaseFirestore.instance.collection('university');

  static CollectionReference _versionCollectionRef =
  FirebaseFirestore.instance.collection('version');
  ///DEVELOP MODE
  static CollectionReference _usersCollectionRef = FirebaseFirestore.instance
      .collection('development/esAH2pX9jWOIxyaMi1v4/users');

  static CollectionReference _chatCollectionRef = FirebaseFirestore.instance
      .collection('development/esAH2pX9jWOIxyaMi1v4/chats');

  static CollectionReference _taskCollectionRef = FirebaseFirestore.instance
      .collection('development/esAH2pX9jWOIxyaMi1v4/tasks');

  static CollectionReference _developmentCollectionRef =
      FirebaseFirestore.instance.collection('development');

  Future sendOpportunityFeedback({List filters, GenchiUser user, String request}) async {
    UserFeedback feedback = UserFeedback(
        filters: filters,
        id: user.id,
        email: user.email,
        name: user.name,
        request:  request,
        timeSubmitted: Timestamp.now());

    await _feedbackCollectionRef.add(feedback.toJson());
  }

  Future addUniveristy({String uni, String email, String reason}) async {

    await _universityCollectionRef
        .add({'univeristy': uni, 'time': Timestamp.now(), 'reason':reason,'email':email});
  }

  Future checkForAppUpdate({String currentVersion}) async {


    DocumentSnapshot versionsData = await _versionCollectionRef.doc('QvfpN3wVCzvsvK1sTu4M').get();
    Map versions = versionsData.data();

    List acceptableVersions = versions['acceptableVersions'];

    ///Tease the user
    await Future.delayed(const Duration(seconds: 2));

    return acceptableVersions.contains(currentVersion);
  }

  ///***------------------ SERVICE SEARCH FUNCTIONS ------------------***

  Future<List<GenchiUser>> fetchServiceProviders() async {
    List<GenchiUser> serviceProviders;
    var result = await _usersCollectionRef
        .where('accountType', isEqualTo: 'Service Provider')
        .get();
    serviceProviders =
        result.docs.map((doc) => GenchiUser.fromMap(doc.data())).toList();
    return serviceProviders;
  }

  Future<List<GenchiUser>> getGroupsByAccountType({String groupType}) async {
    if (debugMode)
      print('FirestoreAPI: getGroupsByAccountType called for $groupType');
    List<GenchiUser> users = [];

    QuerySnapshot result = await _usersCollectionRef
        .where('category', isEqualTo: groupType)
        .where('accountType', isEqualTo: 'Group')
        .get();

    users = result.docs.map((doc) => GenchiUser.fromMap(doc.data())).toList();

    users.sort((a, b) => a.subcategory.compareTo(b.subcategory));

    return users;
  }

  Future<List<GenchiUser>> getProvidersByService({String serviceType}) async {
    QuerySnapshot result = await _usersCollectionRef
        .where('accountType', isEqualTo: 'Service Provider')
        .where('category', isEqualTo: serviceType)
        .get();
    List<GenchiUser> allServiceProviders =
        result.docs.map((doc) => GenchiUser.fromMap(doc.data())).toList();
    return allServiceProviders;
  }

  Future<DocumentReference> addServiceProvider(
      {GenchiUser serviceUser, String uid}) async {
    DocumentReference result = await _usersCollectionRef
        .add(serviceUser.toJson())
        .then((docRef) async {
      await updateUser(
        user: GenchiUser(id: docRef.id),
        uid: docRef.id,
      );

      ///add to main user's profile as well
      await _usersCollectionRef.doc(uid).update({
        'providerProfiles': FieldValue.arrayUnion([docRef.id])
      });
      return docRef;
    });

    return result;
  }

  Future<List<GenchiUser>> getServiceProviders({List ids}) async {
    if (debugMode) print('FirestoreAPI: getServiceProviders called for $ids');
    List<GenchiUser> serviceProviders = [];
    for (var id in ids) {
      GenchiUser serviceProvider = await getUserById(id);

      ///Check that the provider exists
      if (serviceProvider != null) {
        serviceProviders.add(serviceProvider);
      }
    }
    return serviceProviders;
  }

  //TODO: what else is required to delete a normal user account tied to an email?
  Future<void> deleteServiceProvider({GenchiUser serviceProvider}) async {
    if (debugMode)
      print(
          'FirestoreAPI: deleteSerivceProvider called on ${serviceProvider.id}');

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
    for (String taskId in serviceProvider.tasksApplied) {
      if (debugMode)
        print(
            'FirestoreAPI: deleteServiceProvider Removing application from task $taskId');

      ///Find the application corresponding to this provider.id
      QuerySnapshot applications = await _taskCollectionRef
          .doc(taskId)
          .collection(applicantCollectionName)
          .where('applicantId', isEqualTo: serviceProvider.id)
          .get();

      if (applications.docs.isNotEmpty)
        for (DocumentSnapshot doc in applications.docs) {
          await removeTaskApplicant(
              applicantId: serviceProvider.id,
              taskId: taskId,
              applicationId: doc.id);
        }
    }

    ///Delete the provider
    await _usersCollectionRef.doc(serviceProvider.id).delete();

    ///Remove provider from user's array
    await _usersCollectionRef.doc(serviceProvider.mainAccountId).update({
      'providerProfiles': FieldValue.arrayRemove([serviceProvider.id])
    });
    if (debugMode) print('FirestoreAPI: deleteServiceProvider complete');
  }

  ///***------------------ USER FUNCTIONS ------------------***

  Future getUserById(String uid) async {
    var doc = await _usersCollectionRef.doc(uid).get();
    return doc.exists ? GenchiUser.fromMap(doc.data()) : null;
  }

  Future updateUser({GenchiUser user, String uid}) async {
    await _usersCollectionRef.doc(uid).update(user.toJson());
  }

  Future addUserByID(GenchiUser user) async {
    var result = await _usersCollectionRef.doc(user.id).set(user.toJson());
    return result;
  }

  Future addUser(GenchiUser user) async {
    DocumentReference result = await _usersCollectionRef.add(user.toJson());
    return result;
  }

  Future<List<GenchiUser>> getUsersFavourites(userFavourites) async {
    List<GenchiUser> favUsers = [];
    if (debugMode)
      print(
          'FirestoreAPIService: getUserFavourites called on: $userFavourites');
    for (var id in userFavourites) {
      GenchiUser favUser = await getUserById(id);

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
    await _usersCollectionRef.doc(uid).update({
      'favourites': FieldValue.arrayRemove([favouriteId])
    });
    await _usersCollectionRef.doc(favouriteId).update({
      'isFavouritedBy': FieldValue.arrayRemove([uid])
    });
  }

  Future addUserFavourite({String uid, String favouriteId}) async {
    if (debugMode)
      print(
          'FirestoreAPI: addUserFavourite called for user $uid unfavouriting user $favouriteId');
    await _usersCollectionRef.doc(uid).update({
      'favourites': FieldValue.arrayUnion([favouriteId])
    });
    await _usersCollectionRef.doc(favouriteId).update({
      'isFavouritedBy': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> deleteDisplayPicture({GenchiUser user}) async {
    await FirebaseStorage.instance
        .ref()
        .child(user.displayPictureFileName)
        .delete();
    await _usersCollectionRef.doc(user.id).update({
      'displayPictureFileName': FieldValue.delete(),
      'displayPictureURL': FieldValue.delete()
    });

    ///Repeat for users service provider profiles
    if (user.providerProfiles.isNotEmpty)
      for (String id in user.providerProfiles) {
        await _usersCollectionRef.doc(id).update({
          'displayPictureFileName': FieldValue.delete(),
          'displayPictureURL': FieldValue.delete()
        });
      }
  }

  ///***------------------ CHAT FUNCTIONS ------------------***

  Stream<QuerySnapshot> fetchChatStream(String chatId) {
    return _chatCollectionRef
        .doc(chatId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future getChatById(String chatId) async {
    var doc = await _chatCollectionRef.doc(chatId).get();
    return doc.exists ? Chat.fromMap(doc.data()) : null;
  }

  Future updateChat({Chat chat}) async {
    await _chatCollectionRef.doc(chat.chatid).update(chat.toJson());
  }

  Stream streamUserChatsAndApplications({GenchiUser user}) async* {
    ///This function is used to stream all the private chats and applications a user has (and their provider chats)
    if (debugMode)
      print(
          'firestoreApi: streamUserChatsAndApplications called on ${user.id} and ${user.providerProfiles}');

    ///Collating all ids into one list for querying
    List usersProfileIds = [];
    usersProfileIds.add(user.id);
    usersProfileIds.addAll(user.providerProfiles);

    ///Get the tasks the provider profile has applied to!
    List tasksApplied = [];
    List providerProfiles = [];
    providerProfiles.add(user);
    tasksApplied.addAll(user.tasksApplied);

    for (String pid in user.providerProfiles) {
      GenchiUser provider = await getUserById(pid);
      if (provider != null) {
        providerProfiles.add(provider);
        tasksApplied.addAll(provider.tasksApplied);
      }
    }

    ///Getting all the private chats
    Stream stream1 = _chatCollectionRef
        .where('ids', arrayContainsAny: usersProfileIds)
        .snapshots()
        .asyncMap((event) async {
      var futures = event.docs.map((doc) async {
        Chat chat = Chat.fromMap(doc.data());

        ///Check if user is id1 or id2
        bool isUser1 = usersProfileIds.contains(chat.id1);

        ///Get other user's profile
        GenchiUser otherUser = await getUserById(isUser1 ? chat.id2 : chat.id1);

        ///Get the current user's profile (either main or a specific provider profile)
        GenchiUser currentUser;

        for (GenchiUser account in providerProfiles) {
          if (isUser1) {
            if (chat.id1 == account.id) currentUser = account;
          } else {
            if (chat.id2 == account.id) currentUser = account;
          }
        }

        if (otherUser != null && currentUser != null) {
          return {
            'type': 'chat',
            'data': {
              'time': chat.time,
              'chat': chat,
              'otherUser': otherUser,
              'user': currentUser,
              'userIsUser1': isUser1,
            }
          };
        } else
          return {
            'data': {'time': Timestamp.now()}
          };
      });

      return await Future.wait(futures);
    });

    ///Getting the tasks the user has applied to
    Stream stream2 = _taskCollectionRef
        //TODO: is this risky using [' '] as a null entry?
        .where('taskId',
            whereIn: tasksApplied.isNotEmpty ? tasksApplied : [' '])
        .snapshots()
        .asyncMap((event) async {
      var futures = event.docs.map((doc) async {
        Task appliedTask = Task.fromMap(doc.data());
        QuerySnapshot taskApplicationData = await _taskCollectionRef
            .doc(appliedTask.taskId)
            .collection(applicantCollectionName)
            .where('applicantId', whereIn: usersProfileIds)
            .get();

        ///Check that the application has been found (*there should only be one*)
        if (taskApplicationData.docs[0] != null) {
          TaskApplication taskApplication =
              TaskApplication.fromMap(taskApplicationData.docs[0].data());
          GenchiUser currentUser;

          ///Need to check which user account it is and get the account if it's a provider
          for (GenchiUser account in providerProfiles) {
            if (taskApplication.applicantId == account.id)
              currentUser = account;
          }

          ///Need to get the hirer's account
          GenchiUser hirer = await getUserById(taskApplication.hirerid);

          ///Return results as a map
          if (hirer != null && currentUser != null) {
            return {
              'type': 'taskApplied',
              'data': {
                'time': taskApplication.time,
                'application': taskApplication,
                'hirer': hirer,
                'applicant': currentUser,
                'userIsHirer': false,
                'task': appliedTask,
              }
            };
          } else {
            return {
              'data': {'time': Timestamp.now()}
            };
          }
        }
      });

      return await Future.wait(futures);
    });

    ///Getting the tasks the user has posted (service providers can't post tasks so
    ///this is a little more simple)
    Stream stream3 = _taskCollectionRef
        .where('hirerId', isEqualTo: user.id)
        .snapshots()
        .asyncMap((event) async {
      var futures = event.docs.map((doc) async {
        Task postedTask = Task.fromMap(doc.data());

        List<Map<String, dynamic>> taskApplicationsData =
            await getTaskApplicants(task: postedTask);

        ///Filter out any posts that don't have any applicants

        if (taskApplicationsData.isNotEmpty) {
          ///They are ordered by time so the first one will have the latest time
          TaskApplication latestApplication =
              taskApplicationsData.first['application'];

          Timestamp latestTime = latestApplication.time;

          ///Return results as a map
          return {
            'type': 'taskPosted',
            'data': {
              'time': latestTime,
              'task': postedTask,
              'list': taskApplicationsData,
            }
          };
        } else
          return {
            'data': {'time': Timestamp.now()}
          };
      });
      return await Future.wait(futures);
    });

    yield* Rx.combineLatest([stream1, stream2, stream3], (values) => values);
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

    await _chatCollectionRef.doc(chatId).update(chat.toJson());

    var result = await _chatCollectionRef
        .doc(chatId)
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
      await updateChat(chat: Chat(chatid: docRef.id));

      ///Add to senders array
      await _usersCollectionRef.doc(initiatorId).update({
        'chats': FieldValue.arrayUnion([docRef.id])
      });

      ///add to recipient's array
      await _usersCollectionRef.doc(recipientId).update({
        'chats': FieldValue.arrayUnion([docRef.id])
      });
      return docRef;
    });

    return result;
  }

  Future<void> deleteChat({Chat chat}) async {
    ///Deleting chat from users's arrays
    await _usersCollectionRef.doc(chat.id1).update({
      'chats': FieldValue.arrayRemove([chat.chatid])
    });

    await _usersCollectionRef.doc(chat.id2).update({
      'chats': FieldValue.arrayRemove([chat.chatid])
    });

    ///Deleting messages attached to the chat
    await _chatCollectionRef
        .doc(chat.chatid)
        .collection('messages')
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isNotEmpty)
        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
    });

    ///Deleting the chat
    await _chatCollectionRef.doc(chat.chatid).delete();
  }

  Future<void> hideChat({Chat chat, String hiddenId}) async {
    if (debugMode) print('FirestoreAPI: hideChat called');

    ///work out how to hide it from user 1 or user 2
    bool hideForUser1 = hiddenId == chat.id1;

    hideForUser1
        ? chat.isHiddenFromUser1 = true
        : chat.isHiddenFromUser2 = true;

    await updateChat(chat: chat);
  }

  ///***------------------ TASK FUNCTIONS ------------------***

  final String applicantCollectionName = 'applicants';

  Future getTaskById({String taskId}) async {
    DocumentSnapshot doc = await _taskCollectionRef.doc(taskId).get();
    return doc.exists ? Task.fromMap(doc.data()) : null;
  }

  Future updateTask({Task task, String taskId}) async {
    await _taskCollectionRef.doc(taskId).update(task.toJson());
    return;
  }

  //TODO how to fail safe this ???
  Future<DocumentReference> addTask(
      {@required Task task, @required String hirerId}) async {
    DocumentReference result =
        await _taskCollectionRef.add(task.toJson()).then((docRef) async {
      await updateTask(
        task: Task(taskId: docRef.id),
        taskId: docRef.id,
      );
      await _usersCollectionRef.doc(hirerId).update({
        'posts': FieldValue.arrayUnion([docRef.id])
      });
      return docRef;
    });

    return result;
  }

  Future updateTaskApplication({TaskApplication taskApplication}) async {
    await _taskCollectionRef
        .doc(taskApplication.taskid)
        .collection(applicantCollectionName)
        .doc(taskApplication.applicationId)
        .update(taskApplication.toJson());
  }

  Future<List<Map<String, dynamic>>> fetchTasksAndHirers() async {
    ///This function is for fetching all the tasks for the tasks feed
    if (debugMode) print('FirestoreAPI: fetchTasksAndHirers called');

    List<Map<String, dynamic>> tasksAndHirers = [];
    List<Task> tasks;
    List<Task> openTasks = [];
    List<Task> deadlineTasks = [];
    List<Task> newTasks = [];

    var result =
        await _taskCollectionRef.where('status', isEqualTo: 'Vacant').get();

    ///Map all the docs into Task objects
    tasks = result.docs.map((doc) => Task.fromMap(doc.data())).toList();

    for (Task task in tasks) {
      if (task.time.toDate().difference(DateTime.now()).inHours > -36) {
        newTasks.add(task);
      } else if (task.hasFixedDeadline && task.applicationDeadline != null) {
        deadlineTasks.add(task);
      } else {
        openTasks.add(task);
      }
    }

    newTasks.sort((a, b) => b.time.compareTo(a.time));

    deadlineTasks
        .sort((a, b) => a.applicationDeadline.compareTo(b.applicationDeadline));
    openTasks.sort((a, b) => b.time.compareTo(a.time));

    tasks = [];
    tasks.addAll(newTasks);
    tasks.addAll(deadlineTasks);
    tasks.addAll(openTasks);

    for (Task task in tasks) {
      Map<String, dynamic> taskAndHirer = {};
      taskAndHirer['task'] = task;
      var hirer = await getUserById(task.hirerId);

      ///If hirer exists add them to the task list
      if (hirer != null && task.status == 'Vacant') {
        taskAndHirer['hirer'] = hirer;
        tasksAndHirers.add(taskAndHirer);
      }
    }
    return tasksAndHirers;
  }

  Stream<QuerySnapshot> fetchTaskApplicantChatStream(
      {@required String applicationId, @required String taskId}) {
    return _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .doc(applicationId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future getTaskApplicationById(
      {@required String applicationId, @required String taskId}) async {
    DocumentSnapshot doc = await _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .doc(applicationId)
        .get();

    return doc.exists ? TaskApplication.fromMap(doc.data()) : null;
  }

  Future<bool> providerApplicationHasNotification(
      {@required String taskId, @required String applicantId}) async {
    bool hasNotification = false;

    ///Don't need to worry too much about this document not existing as
    ///it is only called for the tasks that the provider has applied to
    QuerySnapshot docs = await _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .where('applicantId', isEqualTo: applicantId)
        .get();

    if (docs.docs.isNotEmpty)
      for (DocumentSnapshot doc in docs.docs) {
        TaskApplication taskApplication = TaskApplication.fromMap(doc.data());

        ///If the taskapplicant has an unread messages then mark the notification as true
        if (taskApplication.applicantHasUnreadMessage) hasNotification = true;
      }

    return hasNotification;
  }

  Future<bool> hirerTaskHasNotification({@required String taskId}) async {
    bool hasNotification = false;

    ///Don't need to worry too much about this document not existing as
    ///it is only called for the tasks that the user has posted
    QuerySnapshot docs = await _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .get();

    if (docs.docs.isNotEmpty)
      for (DocumentSnapshot doc in docs.docs) {
        TaskApplication taskApplication = TaskApplication.fromMap(doc.data());

        ///If the hirer has an unread messages then mark has notification as true
        if (taskApplication.hirerHasUnreadMessage) hasNotification = true;
      }

    return hasNotification;
  }

  Future<List<Map<String, dynamic>>> getTaskApplicants(
      {@required Task task}) async {
    ///This is called to get the applicants attached to a task
    if (debugMode)
      print('FirestoreAPI: getTaskApplicants called on ${task.taskId}');

    List<Map<String, dynamic>> applicationAndProviders = [];

    QuerySnapshot applicants = await _taskCollectionRef
        .doc(task.taskId)
        .collection(applicantCollectionName)
        .get();

    if (applicants.docs.isNotEmpty) {
      ///Map all the docs into Task objects
      List<TaskApplication> tasksApplicants = applicants.docs
          .map((doc) => TaskApplication.fromMap(doc.data()))
          .toList();

      for (TaskApplication application in tasksApplicants) {
        Map<String, dynamic> applicationAndProvider = {};

        if (debugMode)
          print(
              'FirestoreAPI: getTaskChatsAndProviders found application ${application.applicationId} and applicant ${application.applicantId}');

        ///Grab the applicant associated with the application
        GenchiUser applicant = await getUserById(application.applicantId);

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

  Future addMessageToTaskApplicant(
      {@required String applicationId,
      @required String taskId,
      @required ChatMessage chatMessage,
      @required bool applicantIsSender}) async {
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
        .doc(taskId)
        .collection(applicantCollectionName)
        .doc(applicationId)
        .update(taskApplication.toJson());

    ///This ensures that the stream view updates
    await _taskCollectionRef
        .doc(taskId)
        .update({'latestEvent': Timestamp.now()});

    ///Add the message to the task applicant collection
    var result = await _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .doc(applicationId)
        .collection('messages')
        .add(chatMessage.toJson());

    return result;
  }

  Future<DocumentReference> applyToTask(
      {@required String taskId,
      @required String applicantId,
      @required String hirerId}) async {
    if (debugMode)
      print(
          'FirestoreAPI: applyToTask called for task $taskId by applicant $applicantId');

    TaskApplication taskApplication = TaskApplication(
        taskid: taskId,
        hirerid: hirerId,
        time: Timestamp.now(),
        applicantId: applicantId,
        isHiddenFromHirer: false,
        isHiddenFromApplicant: false);

    ///Add application to taskApplication collection
    DocumentReference taskApplicationResult = await _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .add(taskApplication.toJson())
        .then((docRef) async {
      await updateTaskApplication(
          taskApplication:
              TaskApplication(applicationId: docRef.id, taskid: taskId));
      return docRef;
    });

    ///Add taskId to user's tasksApplied
    await _usersCollectionRef.doc(applicantId).update({
      'tasksApplied': FieldValue.arrayUnion([taskId])
    });

    ///Add applicationId to task's applicationIds
    await _taskCollectionRef.doc(taskId).update({
      'applicationIds': FieldValue.arrayUnion([taskApplicationResult.id])
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
    await _usersCollectionRef.doc(applicantId).update({
      'tasksApplied': FieldValue.arrayRemove([taskId])
    });

    ///Remove from the task's array
    await _taskCollectionRef.doc(taskId).update({
      'applicationIds': FieldValue.arrayRemove([applicationId])
    });

    ///Delete all subcollection messages
    await _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .doc(applicationId)
        .collection('messages')
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isNotEmpty)
        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
    });

    ///Deleting the application
    await _taskCollectionRef
        .doc(taskId)
        .collection(applicantCollectionName)
        .doc(applicationId)
        .delete();
  }

  Future<void> deleteTask({Task task}) async {
    if (debugMode) print('FirestoreAPI: deleteTask called for ${task.taskId}');

    ///Removing all applications from the task
    await _taskCollectionRef
        .doc(task.taskId)
        .collection(applicantCollectionName)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in snapshot.docs) {
          TaskApplication taskApplication = TaskApplication.fromMap(doc.data());

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

    ///removing from user's posts
    await _usersCollectionRef.doc(task.hirerId).update({
      'posts': FieldValue.arrayRemove([task.taskId])
    });

    ///Delete the task
    await _taskCollectionRef.doc(task.taskId).delete();
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

      GenchiUser applicant = await getUserById(id);

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

          GenchiUser hirer = await getUserById(task.hirerId);

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

  Future<bool> applicantWasSuccessful(
      {@required Task task, @required String applicantId}) async {
    ///This task is used for checking whether an applicant was successful in an application
    ///It returns true for successful, false for unsuccessful or if they haven't applied
    if (debugMode)
      print(
          'FirestoreAPI: applicantWasSuccessful called for ${task.taskId} and $applicantId');

    List<Map<String, dynamic>> applicationAndProviders = [];

    QuerySnapshot applications = await _taskCollectionRef
        .doc(task.taskId)
        .collection(applicantCollectionName)
        .get();

    if (applications.docs.isNotEmpty) {
      List<TaskApplication> taskApplicants = applications.docs
          .map((doc) => TaskApplication.fromMap(doc.data()))
          .toList();

      for (TaskApplication application in taskApplicants) {
        ///Need to check if the use has applied to the task or not
        if (application.applicantId == applicantId) {
          ///User has applied to task
          if (task.successfulApplications.contains(application.applicationId)) {
            ///User has a successful application
            return true;
          }
        }
      }
    }

    return false;
  }

  Future addViewedIdToTask(
      {@required String viewedId, @required String taskId}) async {
    ///Add viewedId to the tasks viewedId list
    await _taskCollectionRef.doc(taskId).update({
      'viewedIds': FieldValue.arrayUnion([viewedId])
    });
  }

  Future addLinkApplicantId(
      {@required String taskId, @required String applicantId}) async {
    await _taskCollectionRef.doc(taskId).update({
      'linkApplicationIds': FieldValue.arrayUnion([applicantId])
    });
  }

  ///***------------------ OTHER FUNCTIONS ------------------***

  Future addFCMToken(
      {@required GenchiUser user, @required String token}) async {
    ///Update in the main user's account
    await _usersCollectionRef.doc(user.id).update({
      'fcmTokens': FieldValue.arrayUnion([token])
    });
  }

  Future findTaskViewers() async {
    ///Get all tasks
    await _taskCollectionRef.get().then((value1) async {
      for (DocumentSnapshot doc1 in value1.docs) {
        ///Get all the users associated with a task
        Task task = Task.fromMap(doc1.data());

        List viewerIds = task.viewedIds;
        print('');
        print(task.title);

        ///Cycle through viewerIds to get their details
        for (String viewerId in viewerIds) {
          GenchiUser viewerUser = await getUserById(viewerId);

          if (viewerUser != null) {
            print(
                "${viewerUser.id} - ${viewerUser.name} - ${viewerUser.email}");
            print('');
          }
        }

        print('------------------------------------------------');
      }
    });
  }

  Future preferencAggregate() async {
    Map opportunityValues = {};

    await _usersCollectionRef.get().then((value) async {
      for (DocumentSnapshot doc1 in value.docs) {
        GenchiUser theUser = GenchiUser.fromMap(doc1.data());
        if (theUser.preferences.isNotEmpty) {
          for (String value in theUser.preferences) {
            if (opportunityValues.containsKey(value)) {
              opportunityValues[value] += 1;
            } else {
              opportunityValues[value] = 1;
            }
          }
        }
      }
    });

    print(opportunityValues);
  }

  Future weightedPreferencAggregate() async {
    Map opportunityValuesViewed = {};
    Map opportunityValuesApplied = {};

    await _taskCollectionRef.get().then((value) async {
      for (DocumentSnapshot doc1 in value.docs) {
        print('1');
        Task task = Task.fromMap(doc1.data());
        if (task.viewedIds.isNotEmpty) {
          for (String id in task.viewedIds) {
            ///Get the user and get their preferences
            GenchiUser user = await getUserById(id);
            if (user != null) {
              for (String value in user.preferences) {
                if (opportunityValuesViewed.containsKey(value)) {
                  opportunityValuesViewed[value] += 1;
                } else {
                  opportunityValuesViewed[value] = 1;
                }
              }
            }
          }
        }
        print('2');
        if (task.linkApplicationIds.isNotEmpty) {
          for (String id in task.linkApplicationIds) {
            ///Get the user and get their preferences
            GenchiUser user = await getUserById(id);
            if (user != null) {
              for (String value in user.preferences) {
                if (opportunityValuesApplied.containsKey(value)) {
                  opportunityValuesApplied[value] += 1;
                } else {
                  opportunityValuesApplied[value] = 1;
                }
              }
            }
          }
        }
        print('3');
        if (task.applicationIds.isNotEmpty) {
          for (String id in task.applicationIds) {
            ///Get the user and get their preferences
            GenchiUser user = await getUserById(id);
            if (user != null) {
              for (String value in user.preferences) {
                if (opportunityValuesApplied.containsKey(value)) {
                  opportunityValuesApplied[value] += 1;
                } else {
                  opportunityValuesApplied[value] = 1;
                }
              }
            }
          }
        }
      }
    });

    print(opportunityValuesViewed);
    print(opportunityValuesApplied);
  }

  Future taskTagsAggregate() async {
    Map tagsAggregate = {};

    await _taskCollectionRef.get().then((value) async {
      for (DocumentSnapshot doc1 in value.docs) {
        Task task = Task.fromMap(doc1.data());

        if (task.tags.isNotEmpty) {
          for (String tag in task.tags) {
            if (tagsAggregate.containsKey(tag)) {
              tagsAggregate[tag] += 1;
            } else {
              tagsAggregate[tag] = 1;
            }
          }
        }
      }
    });

    print(tagsAggregate);
  }

  Future taskViewApplyRatio() async {
    Map ratioAggregate = {};

    await _taskCollectionRef.get().then((value) async {
      for (DocumentSnapshot doc1 in value.docs) {
        Task task = Task.fromMap(doc1.data());

        print({
          "name": task.title,
          "views": task.viewedIds.length,
          "applications":
              task.applicationIds.length + task.linkApplicationIds.length
        });

        ratioAggregate[task.title] = {
          "views": task.viewedIds.length,
          "applications":
              task.applicationIds.length + task.linkApplicationIds.length
        };
      }
    });

    print(ratioAggregate);
  }

  Future taskTagWeightingsAggregate() async {
    Map viewAggregate = {};
    Map applyAggregate = {};

    await _taskCollectionRef.get().then((value) async {
      for (DocumentSnapshot doc1 in value.docs) {
        Task task = Task.fromMap(doc1.data());

        for (String tag in task.tags) {
          if (viewAggregate.containsKey(tag)) {
            viewAggregate[tag] += 1 * task.viewedIds.length;
          } else {
            viewAggregate[tag] = 1 * task.viewedIds.length;
          }

          if (applyAggregate.containsKey(tag)) {
            applyAggregate[tag] += 1 *
                (task.linkApplicationIds.length + task.applicationIds.length);
          } else {
            applyAggregate[tag] = 1 *
                (task.linkApplicationIds.length + task.applicationIds.length);
          }
        }
      }
    });

    print(viewAggregate);
    print(applyAggregate);
  }

  Future leadingUsers() async {
    List leadingUsers = [];

    await _usersCollectionRef.get().then((value) async {
      for (DocumentSnapshot doc1 in value.docs) {
        GenchiUser user = GenchiUser.fromMap(doc1.data());

        leadingUsers.add([user.name,user.sessionCount]);


      }
    });

    leadingUsers.sort((a, b) => b[1].compareTo(a[1]));
    print(leadingUsers);

  }

  ///Must only call this whilst in PRODUCTION MODE
  Future createDevEnvironment() async {
    ///grab all data from firestore
    ///send under the development collection

    DocumentReference devDoc =
        await _developmentCollectionRef.add({'timeStamp': Timestamp.now()});

    ///chats
    await FirebaseFirestore.instance
        .collection('chats')
        .get()
        .then((value1) async {
      for (DocumentSnapshot doc1 in value1.docs) {
        ///Add to firebase dev collection
        await _developmentCollectionRef
            .doc(devDoc.id)
            .collection('chats')
            .doc(doc1.id)
            .set(doc1.data());

        ///grab sub collection docs for each document
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(doc1.id)
            .collection('messages')
            .get()
            .then((value2) async {
          ///add sub collection docs to dev collection
          for (DocumentSnapshot doc2 in value2.docs) {
            await _developmentCollectionRef
                .doc(devDoc.id)
                .collection('chats')
                .doc(doc1.id)
                .collection('messages')
                .doc(doc2.id)
                .set(doc2.data());
          }
        });
      }
    });

    ///Users
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value1) async {
      for (DocumentSnapshot doc1 in value1.docs) {
        ///Add to firebase dev collection
        await _developmentCollectionRef
            .doc(devDoc.id)
            .collection('users')
            .doc(doc1.id)
            .set(doc1.data());
      }
    });

    ///Tasks
    await FirebaseFirestore.instance
        .collection('tasks')
        .get()
        .then((value1) async {
      for (DocumentSnapshot doc1 in value1.docs) {
        ///Add to firebase dev collection
        await _developmentCollectionRef
            .doc(devDoc.id)
            .collection('tasks')
            .doc(doc1.id)
            .set(doc1.data());

        ///grab sub collection docs for each document
        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(doc1.id)
            .collection('applicants')
            .get()
            .then((value2) async {
          for (DocumentSnapshot doc2 in value2.docs) {
            ///add sub collection docs to dev collection
            await _developmentCollectionRef
                .doc(devDoc.id)
                .collection('tasks')
                .doc(doc1.id)
                .collection('applicants')
                .doc(doc2.id)
                .set(doc2.data());

            ///grab sub collection docs for each document
            await FirebaseFirestore.instance
                .collection('tasks')
                .doc(doc1.id)
                .collection('applicants')
                .doc(doc2.id)
                .collection('messages')
                .get()
                .then((value3) async {
              for (DocumentSnapshot doc3 in value3.docs) {
                ///add sub collection docs to dev collection
                await _developmentCollectionRef
                    .doc(devDoc.id)
                    .collection('tasks')
                    .doc(doc1.id)
                    .collection('applicants')
                    .doc(doc2.id)
                    .collection('messages')
                    .doc(doc3.id)
                    .set(doc3.data());
              }
            });
          }
        });
      }
    });
    print('Done');
  }

  Future addTaskApplications() async {
    await _taskCollectionRef.get().then(
      (value1) async {
        for (DocumentSnapshot doc in value1.docs) {
          Task task = doc.exists ? Task.fromMap(doc.data()) : null;

          if (task != null) {
            List<String> applicationIds = [];

            await _taskCollectionRef
                .doc(task.taskId)
                .collection('applicants')
                .get()
                .then((value2) async {
              for (DocumentSnapshot doc2 in value2.docs) {
                applicationIds.add(doc2.id);
              }
            });

            task.status = 'Vacant';
            task.applicationIds = applicationIds;
            await updateTask(task: task, taskId: task.taskId);
          }
        }
      },
    );

    print('done');
  }
}
