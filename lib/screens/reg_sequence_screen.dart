import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
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
          Container(
            height: MediaQuery.of(context).size.height*0.5,
            child: RaisedButton(
              color: Color(kGenchiOrange),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.id, (Route<dynamic> route) => false);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text("I am a Hirer",
                      //TODO: ADD FUTURA FONT
                      style: TextStyle(
                        color: Color(kGenchiBlue),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.pan_tool,
                      size: 100,
                      color: Color(kGenchiBlue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height*0.5,
            child: RaisedButton(
              color: Color(kGenchiBlue),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, HomeScreen.id, (Route<dynamic> route) => false);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text("I am a Provider",
                      //TODO: ADD FUTURA FONT
                      style: TextStyle(
                        color: Color(kGenchiOrange),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.accessible_forward,
                      size: 100,
                      color: Color(kGenchiOrange),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
