import 'package:flutter/material.dart';
import 'firestore_api_service.dart';

import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/constants.dart';



class TaskService extends ChangeNotifier {

  final FirestoreAPIService _firestoreAPI = FirestoreAPIService();


  Task _currentTask;
  Task get currentTask => _currentTask;


  Future updateCurrentTask({String taskId}) async {

    if(debugMode) print("updateCurrentTask called: populating task");
    if (taskId != null) {
      _currentTask = await _firestoreAPI.getTaskById(taskId: taskId);
      notifyListeners();
    }
  }


}
