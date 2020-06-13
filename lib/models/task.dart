

class Task {

  String taskId;
  String hirerId;
  String service;
  String title;
  String details;
  String date;
  List<dynamic> applicantIds;


  Task({
    this.taskId,
    this.hirerId,
    this.service,
    this.title,
    this.details,
    this.date,
    this.applicantIds,
    });

  Task.fromMap(Map snapshot) :
      taskId = snapshot['taskId'] ?? '',
        hirerId = snapshot['hirerId'] ?? '',
        service = snapshot['service'] ?? '',
        title = snapshot['title'] ?? '',
        details = snapshot['details'] ?? '',
        date = snapshot['date'] ?? '',
        applicantIds = snapshot['applicantIds'] ?? [];

  toJson() {
    return {
      if(taskId != null) 'taskId' : taskId,
      if(hirerId != null) 'hirerId' : hirerId,
      if(service != null) 'service' : service,
      if(title != null) 'title' : title,
      if(details != null) 'details' : details,
      if(date != null) 'date' : date,
      if(applicantIds != null) 'applicantIds' : applicantIds,
    };
  }

}