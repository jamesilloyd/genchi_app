import 'package:cloud_firestore/cloud_firestore.dart';

class UserFeedback {
  List<dynamic> filters;
  String email;
  String name;
  String id;
  String request;
  Timestamp timeSubmitted;

  UserFeedback(
      {this.filters, this.name, this.id, this.email, this.timeSubmitted, this.request});

  toJson() {
    return {
      if (request != null) "request":request,
      if (filters != null) "filters": filters,
      if (name != null) "name": name,
      if (id != null) "id": id,
      if (email != null) "email": email,
      if (timeSubmitted != null) 'timeSubmitted': timeSubmitted,
    };
  }
}
