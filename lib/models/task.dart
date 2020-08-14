import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  String applicantid;
  String hirerid;
  String applicationId;
  String taskid;
  bool applicantIsUser;
  bool hirerHasUnreadMessage;
  bool providerHasUnreadMessage;
  bool isHiddenFromHirer;
  bool isHiddenFromProvider;
  String lastMessage;
  Timestamp time;

  TaskApplicant(
      { this.applicantid,
        this.hirerid,
        this.applicationId,
        this.taskid,
        @required this.applicantIsUser,
        this.hirerHasUnreadMessage,
        this.providerHasUnreadMessage,
        this.lastMessage,
        this.isHiddenFromProvider,
        this.isHiddenFromHirer,
        this.time});

  TaskApplicant.fromMap(Map snapshot)
      : applicantid = snapshot['applicantid'] ?? snapshot['pid'] ?? '',
        hirerid = snapshot['hirerid'] ?? '',
        applicantIsUser = snapshot['applicantIsUser'] ?? false,
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
      if (applicantid != null) "applicantid": applicantid,
      if (hirerid != null) "hirerid": hirerid,
      if (applicationId != null) 'applicationId': applicationId,
      if (applicantIsUser != null) 'applicantIsUser' : applicantIsUser,
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

