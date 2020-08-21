import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:package_info/package_info.dart';


class TestScreen extends StatefulWidget {
  static const id = 'test_screen';

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  FirestoreAPIService firestoreApi = FirestoreAPIService();
  bool spinner = false;

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
                buttonTitle: 'Get version',
                buttonColor: Color(kGenchiOrange),
                onPressed: () async {
//                  await firestoreApi.migrateToNewDatabaseArchitecture();
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();

                  print(packageInfo.appName);
                  print(packageInfo.packageName);
                  print(packageInfo.version);
                  print(packageInfo.buildNumber);

                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
