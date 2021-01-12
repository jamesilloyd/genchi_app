import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
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


  bool isExpanded = false;
  BuildContext draggableSheetContext;

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            child: Container(
              child: Text(
                    'Select Date',
              ),
            ),
            onTap: () => _selectDate(context),

              // if (deadlineDateDT != null) {
              //   deadlineDate =
              //       Timestamp.fromMicrosecondsSinceEpoch(
              //           deadlineDateDT
              //               .microsecondsSinceEpoch);
              //   setState(() {});
              // }

          ),
        ),
      ),
    );
  }

}
