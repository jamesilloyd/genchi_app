import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String getSummaryTime({@required Timestamp time}) {

  if((time.toDate().day == DateTime.now().day) & (time.toDate().month == DateTime.now().month) & (time.toDate().year == DateTime.now().year)) {
    //Same day
    var formatter = new DateFormat.Hm();
    String formatted = formatter.format(time.toDate());
    return formatted;
  } else if ((time.toDate().difference(DateTime.now()).inDays < -1) & (time.toDate().difference(DateTime.now()).inDays > -7)) {
    //More than one day, but less than a week
    var formatter = new DateFormat.E();
    String formatted = formatter.format(time.toDate());
    return formatted;
  } else {
    var formatter = new DateFormat.MMMMd();
    String formatted = formatter.format(time.toDate());
    return formatted;
  }
}

String getMessageBubbleTime({@required Timestamp time}) {

  if((time.toDate().day == DateTime.now().day) & (time.toDate().month == DateTime.now().month) & (time.toDate().year == DateTime.now().year)) {
    //Same day
    var formatter = new DateFormat.Hm();
    String formatted = formatter.format(time.toDate());
    return formatted;
  } else if ((time.toDate().difference(DateTime.now()).inDays < -1) & (time.toDate().difference(DateTime.now()).inDays > -7)) {
    //More than one day, but less than a week
    var formatter = new DateFormat.E().add_Hm();
    String formatted = formatter.format(time.toDate());
    return formatted;
  } else {
    var formatter = new DateFormat.MMMMd().add_Hm();
    String formatted = formatter.format(time.toDate());
    return formatted;
  }
}