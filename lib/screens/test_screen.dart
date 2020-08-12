import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class TestScreen extends StatefulWidget {
  static const id = 'test_screen';

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  FirestoreAPIService firestoreApi = FirestoreAPIService();
  bool spinner = false;

  static CollectionReference dev1 = Firestore.instance.collection('development/sSqkhUUghSa8kFVLE05Z/providers/');


  static CollectionReference dev2 = Firestore.instance.collection('development').document('sSqkhUUghSa8kFVLE05Z').collection('providers');
//  static CollectionReference dev3 = devRef.document('sSqkhUUghSa8kFVLE05Z').collection('providers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        progressIndicator: CircularProgress(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              RoundedButton(
                onPressed: () async {

                  setState((){
                    spinner = true;
                  });

//                  CollectionReference ref = Firestore.instance.collection('providers');

                  DocumentSnapshot doc = await dev1.document('gFBcrf33a91kUzmj7OmY').get();
//                  DocumentSnapshot doc = await Firestore.instance.collection('providers').document('gFBcrf33a91kUzmj7OmY').get();
                  print(doc.data);

                  print('done');
//                  await firestoreApi.createDevEnvironment();

                  setState(() {
                    spinner = false;
                  });
                },
                buttonTitle: 'Create development environment',
                buttonColor: Color(kGenchiOrange),
              )


            ],
          ),
        ),
      ),
    );
  }
}
