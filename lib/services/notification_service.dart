import 'package:flutter/material.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

class NotificationService extends ChangeNotifier {


  int _notifications = 0;
  int get notifications => _notifications;

  static FirestoreAPIService firestoreAPI = FirestoreAPIService();

  void updateJobNotificationsFire({GenchiUser user}) async {
    print('updating Job notification firebase');

    _notifications = await firestoreAPI.userHasNotification(user: user);
    notifyListeners();
  }

  void updateJobNotifications({int notifications}) {
    _notifications = notifications;
    // notifyListeners();
  }

}