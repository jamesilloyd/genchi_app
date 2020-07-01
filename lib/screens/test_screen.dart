import 'package:flutter/material.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

class TestScreen extends StatelessWidget {

  FirestoreAPIService firestoreApi = FirestoreAPIService();
  static const id = 'test_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: firestoreApi.getUserById('askjdhfba'),
          builder: (context,snapshot){

            if(snapshot.hasData) {

              return Text('Snapshot data: ${snapshot.data}');


            } else {
              return Text('Getting data');
            }

          },
        ),
      ),
    );
  }
}
