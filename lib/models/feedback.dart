import 'package:cloud_firestore/cloud_firestore.dart';

class UserFeedback {
  List<dynamic> filters;
  String email;
  String name;
  String id;
  Timestamp timeSubmitted;

  UserFeedback(
      {this.filters, this.name, this.id, this.email, this.timeSubmitted});

  toJson() {
    return {
      if (filters != null) "filters": filters,
      if (name != null) "name": name,
      if (id != null) "id": id,
      if (email != null) "email": email,
      if (timeSubmitted != null) 'timeSubmitted': timeSubmitted,
    };
  }
}
