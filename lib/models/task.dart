import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String taskId;
  String hirerId;
  String service;
  String title;
  String details;
  String date;
  String price;
  String status;
  List<dynamic> chosenApplicantIds;
  List<dynamic> applicationIds;
  Timestamp time;

  Task({
    this.taskId,
    this.hirerId,
    this.service,
    this.title,
    this.details,
    this.date,
    this.price,
    this.status,
    this.chosenApplicantIds,
    this.applicationIds,
    this.time,
  });


  Task.fromMap(Map snapshot)
      : taskId = snapshot['taskId'],
        hirerId = snapshot['hirerId'] ?? '',
        service = snapshot['service'] ?? '',
        title = snapshot['title'] ?? '',
        details = snapshot['details'] ?? '',
        date = snapshot['date'] ?? '',
        time = snapshot['time'] ?? Timestamp.now(),
        price = snapshot['price'] ?? '',
        status = snapshot['status']?? 'Vacant',
        chosenApplicantIds = snapshot['chosenApplicantIds'] ?? [],
        applicationIds = snapshot['applicationIds'] ?? [];

  Map<String, dynamic> toJson() {
    return {
      if (taskId != null) 'taskId': taskId,
      if (hirerId != null) 'hirerId': hirerId,
      if (service != null) 'service': service,
      if (title != null) 'title': title,
      if (details != null) 'details': details,
      if (price != null) 'price': price,
      if (date != null) 'date': date,
      if (status != null) 'status':status,
      if (chosenApplicantIds != null) 'chosenApplicantIds': chosenApplicantIds,
      if (applicationIds != null) 'applicationIds': applicationIds,
      if (time != null) 'time': time,
    };
  }
}


List<String> taskStatus = [
  'Vacant',
  'InProgress',
  'Completed'
];



class TaskApplication {

  String taskid;
  String applicationId;
  String applicantId;
  String hirerid;
  bool hirerHasUnreadMessage;
  bool applicantHasUnreadMessage;
  bool isHiddenFromHirer;
  bool isHiddenFromApplicant;
  String lastMessage;
  Timestamp time;

  TaskApplication(
      { this.applicantId,
        this.hirerid,
        this.applicationId,
        this.taskid,
        this.hirerHasUnreadMessage,
        this.applicantHasUnreadMessage,
        this.lastMessage,
        this.isHiddenFromApplicant,
        this.isHiddenFromHirer,
        this.time});

  TaskApplication.fromMap(Map snapshot)
      : applicantId = snapshot['applicantId'] ?? snapshot['pid'] ?? snapshot['applicantid']??'',
        hirerid = snapshot['hirerid'] ?? '',
        hirerHasUnreadMessage = snapshot['hirerHasUnreadMessage'] ?? false,
        applicantHasUnreadMessage = snapshot['applicantHasUnreadMessage'] ?? snapshot['providerHasUnreadMessage'] ?? false,
        lastMessage = snapshot['lastMessage'] ?? '',
        applicationId = snapshot['applicationId'],
        isHiddenFromApplicant = snapshot['isHiddenFromApplicant'] ?? snapshot['isHiddenFromProvider'] ?? false,
        isHiddenFromHirer = snapshot['isHiddenFromHirer'] ?? false,
        taskid = snapshot['taskid'] ?? '',
        time = snapshot['time'] ?? Timestamp.now();

  toJson() {
    return {
      if (applicantId != null) "applicantId": applicantId,
      if (hirerid != null) "hirerid": hirerid,
      if (applicationId != null) 'applicationId': applicationId,
      if (applicantHasUnreadMessage != null)'applicantHasUnreadMessage': applicantHasUnreadMessage,
      if (hirerHasUnreadMessage != null)'hirerHasUnreadMessage': hirerHasUnreadMessage,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (isHiddenFromApplicant != null)"isHiddenFromApplicant": isHiddenFromApplicant,
      if (isHiddenFromHirer != null) "isHiddenFromHirer": isHiddenFromHirer,
      if (time != null) "time" : time,
      if (taskid != null) 'taskid': taskid
    };
  }
}

