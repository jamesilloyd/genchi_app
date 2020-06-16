import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String taskId;
  String hirerId;
  String service;
  String title;
  String details;
  String date;
  List<dynamic> chosenApplicantIds;
  List<dynamic> applicantChatsAndPids;
  Timestamp time;

  Task({
    this.taskId,
    this.hirerId,
    this.service,
    this.title,
    this.details,
    this.date,
    this.chosenApplicantIds,
    this.applicantChatsAndPids,
    this.time,
  });

  Task.fromMap(Map snapshot)
      : taskId = snapshot['taskId'] ?? '',
        hirerId = snapshot['hirerId'] ?? '',
        service = snapshot['service'] ?? '',
        title = snapshot['title'] ?? '',
        details = snapshot['details'] ?? '',
        date = snapshot['date'] ?? '',
        applicantChatsAndPids = snapshot['applicantChatsAndPids'] ?? [],
        time = snapshot['time'] ?? Timestamp.now(),
        chosenApplicantIds = snapshot['chosenApplicantIds'] ?? [];

  Map<String, dynamic> toJson() {
    return {
      if (taskId != null) 'taskId': taskId,
      if (hirerId != null) 'hirerId': hirerId,
      if (service != null) 'service': service,
      if (title != null) 'title': title,
      if (details != null) 'details': details,
      if (date != null) 'date': date,
      if (chosenApplicantIds != null) 'chosenApplicantIds': chosenApplicantIds,
      if (time != null) 'time': time,
      if (applicantChatsAndPids != null)
        'applicantChatsAndPids': applicantChatsAndPids,
    };
  }
}
