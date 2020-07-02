import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

class TestScreen extends StatelessWidget {

  CollectionReference _testCollectionReference = Firestore.instance.collection('test');

  FirestoreAPIService firestoreApi = FirestoreAPIService();
  static const id = 'test_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            RoundedButton(
              buttonColor: Color(kGenchiBlue),
              buttonTitle: 'Set Data',
              onPressed: ()async{

                _testCollectionReference.document('1234').setData({'a':6},merge: true);


              },
            ),
            RoundedButton(
              buttonColor: Color(kGenchiOrange),
              buttonTitle: 'Update Data',
              onPressed: () async{

                try {
                  await _testCollectionReference.document('12345').updateData({'a': 6});
                } catch (e) {
                  print(e);
                }

              },
            )

          ],
        ),
      ),
    );
  }
}
