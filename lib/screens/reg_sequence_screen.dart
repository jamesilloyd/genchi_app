import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'home_screen.dart';

class RegSequenceScreen extends StatefulWidget {
  static const String id = "reg_sequence_screen";
  @override
  _RegSequenceScreenState createState() => _RegSequenceScreenState();
}

class _RegSequenceScreenState extends State<RegSequenceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Text("What brings you here?"),
          ),
          Container(
            height: 20.0,
          ),
          RoundedButton(
            buttonColor: Colors.lightBlueAccent,
            buttonTitle: "Hirer",
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.id, (Route<dynamic> route) => false);
            },
          ),
          RoundedButton(
            buttonColor: Colors.greenAccent,
            buttonTitle: "Provider",
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.id, (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
