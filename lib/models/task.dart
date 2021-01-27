import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: maybe change the name due to conflicting types from cloud firestore
class Task {
  String taskId;
  String hirerId;
  String service;
  String title;
  String details;
  String date;
  String price;
  String status;
  String applicationLink;
  bool linkApplicationType;
  List<dynamic> successfulApplications;
  List<dynamic> unsuccessfulApplications;
  List<dynamic> applicationIds;
  List<dynamic> viewedIds;
  List<dynamic> linkApplicationIds;
  Timestamp time;
  Timestamp applicationDeadline;
  bool hasFixedDeadline;
  List<dynamic> tags;
  List<dynamic> universities;

  Task({
    this.taskId,
    this.hirerId,
    this.service,
    this.title,
    this.details,
    this.date,
    this.price,
    this.status,
    this.applicationLink,
    this.linkApplicationType,
    this.successfulApplications,
    this.unsuccessfulApplications,
    this.applicationIds,
    this.viewedIds,
    this.linkApplicationIds,
    this.time,
    this.applicationDeadline,
    this.hasFixedDeadline,
    this.tags,
    this.universities,
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
        status = snapshot['status'] ?? 'Vacant',
        applicationLink = snapshot['applicationLink'] ?? '',
        linkApplicationType = snapshot['linkApplicationType'] ?? false,
        successfulApplications = snapshot['successfulApplications'] ?? [],
        unsuccessfulApplications = snapshot['unsuccessfulApplications'] ?? [],
        viewedIds = snapshot['viewedIds'] ?? [],
        linkApplicationIds = snapshot['linkApplicationIds'] ?? [],
        ///This is not initialed because if a job is open, then we will put them after
        applicationDeadline = snapshot['applicationDeadline'],
        hasFixedDeadline = snapshot['hasFixedDeadline'] ?? false,
        tags = snapshot['tags'] ?? [],
  //TODO: take this out later 1.0.18
        universities = snapshot['universities'] ?? ['Cambridge'],
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
      if (applicationLink != null) 'applicationLink' :applicationLink,
      if(linkApplicationType != null) 'linkApplicationType':linkApplicationType,
      if (status != null) 'status': status,
      if (successfulApplications != null)
        'successfulApplications': successfulApplications,
      if (unsuccessfulApplications != null)
        'unsuccessfulApplications': unsuccessfulApplications,
      if (applicationIds != null) 'applicationIds': applicationIds,
      if (viewedIds != null) 'viewedIds': viewedIds,
      if (linkApplicationIds !=null) 'linkApplicationIds':linkApplicationIds,
      if (applicationDeadline != null) 'applicationDeadline':applicationDeadline,
      if (hasFixedDeadline != null) 'hasFixedDeadline':hasFixedDeadline,
      if (time != null) 'time': time,
      if (universities != null) 'universities':universities,
      if (tags !=null) 'tags': tags,
    };
  }
}

List<String> taskStatus = ['Vacant', 'InProgress', 'Completed'];

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
      {this.applicantId,
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
      : applicantId = snapshot['applicantId'] ??
            snapshot['pid'] ??
            snapshot['applicantid'] ??
            '',
        hirerid = snapshot['hirerid'] ?? '',
        hirerHasUnreadMessage = snapshot['hirerHasUnreadMessage'] ?? false,
        applicantHasUnreadMessage = snapshot['applicantHasUnreadMessage'] ??
            snapshot['providerHasUnreadMessage'] ??
            false,
        lastMessage = snapshot['lastMessage'] ?? '',
        applicationId = snapshot['applicationId'],
        isHiddenFromApplicant = snapshot['isHiddenFromApplicant'] ??
            snapshot['isHiddenFromProvider'] ??
            false,
        isHiddenFromHirer = snapshot['isHiddenFromHirer'] ?? false,
        taskid = snapshot['taskid'] ?? '',
        time = snapshot['time'] ?? Timestamp.now();

  toJson() {
    return {
      if (applicantId != null) "applicantId": applicantId,
      if (hirerid != null) "hirerid": hirerid,
      if (applicationId != null) 'applicationId': applicationId,
      if (applicantHasUnreadMessage != null)
        'applicantHasUnreadMessage': applicantHasUnreadMessage,
      if (hirerHasUnreadMessage != null)
        'hirerHasUnreadMessage': hirerHasUnreadMessage,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (isHiddenFromApplicant != null)
        "isHiddenFromApplicant": isHiddenFromApplicant,
      if (isHiddenFromHirer != null) "isHiddenFromHirer": isHiddenFromHirer,
      if (time != null) "time": time,
      if (taskid != null) 'taskid': taskid
    };
  }
}
