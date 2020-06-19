import 'package:flutter_test/flutter_test.dart';
import 'package:genchi_app/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Should return JSON format', () {
    final task = Task(
      time: Timestamp.now(),
      taskId: 'abcd',
      title: 'Title',
      details: 'details',
      service: 'Service',
      date: 'Date',
      hirerId: 'hirerId',
//      chosenApplicantIds: ['applicant1', 'applicant2'],
//        applicantChatsAndPids: [{'chat':}]
    );


    Map<String,dynamic> answer = {'taskId': task.taskId, 'hirerId' : task.hirerId,
      'service' : task.service,
      'title' : task.title,
      'details' : task.details,
      'date' : task.date,
//      'chosenApplicantIds' : task.chosenApplicantIds,
      'time' : task.time};


    expect(task.toJson(), answer);
  });
}
