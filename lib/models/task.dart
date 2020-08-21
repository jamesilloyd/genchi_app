import 'package:cloud_firestore/cloud_firestore.dart';


class Task {
  String taskId;
  String hirerId;
  String service;
  String title;
  String details;
  String date;
  String price;
  List<dynamic> chosenApplicantIds;
  Timestamp time;

  Task({
    this.taskId,
    this.hirerId,
    this.service,
    this.title,
    this.details,
    this.date,
    this.price,
    this.chosenApplicantIds,
    this.time,
  });



  Task.fromMap(Map snapshot)
      : taskId = snapshot['taskId'] ?? '',
        hirerId = snapshot['hirerId'] ?? '',
        service = snapshot['service'] ?? '',
        title = snapshot['title'] ?? '',
        details = snapshot['details'] ?? '',
        date = snapshot['date'] ?? '',
        time = snapshot['time'] ?? Timestamp.now(),
        price = snapshot['price'] ?? '',
        chosenApplicantIds = snapshot['chosenApplicantIds'] ?? [];

  Map<String, dynamic> toJson() {
    return {
      if (taskId != null) 'taskId': taskId,
      if (hirerId != null) 'hirerId': hirerId,
      if (service != null) 'service': service,
      if (title != null) 'title': title,
      if (details != null) 'details': details,
      if (price != null) 'price': price,
      if (date != null) 'date': date,
      if (chosenApplicantIds != null) 'chosenApplicantIds': chosenApplicantIds,
      if (time != null) 'time': time,
    };
  }
}



class TaskApplicant {
  String pid;
  String hirerid;
  String applicationId;
  String taskid;
  bool hirerHasUnreadMessage;
  bool providerHasUnreadMessage;
  bool isHiddenFromHirer;
  bool isHiddenFromProvider;
  String lastMessage;
  Timestamp time;

  TaskApplicant(
      {this.pid,
        this.hirerid,
        this.applicationId,
        this.taskid,
        this.hirerHasUnreadMessage,
        this.providerHasUnreadMessage,
        this.lastMessage,
        this.isHiddenFromProvider,
        this.isHiddenFromHirer,
        this.time});

  TaskApplicant.fromMap(Map snapshot)
      : pid = snapshot['pid'] ?? '',
        hirerid = snapshot['hirerid'] ?? '',
        hirerHasUnreadMessage = snapshot['hirerHasUnreadMessage'] ?? false,
        providerHasUnreadMessage = snapshot['providerHasUnreadMessage'] ?? false,
        lastMessage = snapshot['lastMessage'] ?? '',
        applicationId = snapshot['applicationId'] ?? '',
        isHiddenFromProvider = snapshot['isHiddenFromProvider'] ?? false,
        isHiddenFromHirer = snapshot['isHiddenFromHirer'] ?? false,
        taskid = snapshot['taskid'] ?? '',
        time = snapshot['time'] ?? Timestamp.now();

  toJson() {
    return {
      if (pid != null) "pid": pid,
      if (hirerid != null) "hirerid": hirerid,
      if (applicationId != null) 'applicationId': applicationId,
      if (providerHasUnreadMessage != null)'providerHasUnreadMessage': providerHasUnreadMessage,
      if (hirerHasUnreadMessage != null)'hirerHasUnreadMessage': hirerHasUnreadMessage,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (isHiddenFromProvider != null)"isHiddenFromProvider": isHiddenFromProvider,
      if (isHiddenFromHirer != null) "isHiddenFromHirer": isHiddenFromHirer,
      if (time != null) "time" : time,
      if (taskid != null) 'taskid': taskid
    };
  }
}

