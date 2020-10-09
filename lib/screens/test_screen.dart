import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:package_info/package_info.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TestScreen extends StatefulWidget {
  static const id = 'test_screen';

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  FirestoreAPIService firestoreApi = FirestoreAPIService();
  final ScrollController _listScrollController = ScrollController();

  PanelController panelController = PanelController();
  bool spinner = false;

  static const List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  static const double minExtent = 0.2;
  static const double maxExtent = 0.6;

  bool isExpanded = false;
  double initialExtent = minExtent;
  BuildContext draggableSheetContext;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: RoundedButton(
            buttonColor: Color(kGenchiGreen),
            buttonTitle: 'Crashlytics Enables?',
            onPressed: ()async{


            },
          ),
        ),
      ),
    );
  }

}
