import 'package:flutter/material.dart';
import 'firestore_api_service.dart';

import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/constants.dart';



class TaskService extends ChangeNotifier {

  final FirestoreAPIService _firestoreAPI = FirestoreAPIService();


  Task _currentTask;
  Task get currentTask => _currentTask;


  Future updateCurrentTask({String taskId}) async {

    if(debugMode) print("updateCurrentTask called: populating task $taskId");
    if (taskId != null) {
      Task task = await _firestoreAPI.getTaskById(taskId: taskId);
      if(task!=null) {
        _currentTask = task;
        notifyListeners();
      } else {
        //TODO how to handle this???
      }

    }
  }


}
