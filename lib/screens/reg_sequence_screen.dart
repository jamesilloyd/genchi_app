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
      backgroundColor: Color(kGenchiGreen),
      body: Padding(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.05, MediaQuery.of(context).size.height*0.05, MediaQuery.of(context).size.width*0.05, MediaQuery.of(context).size.height*0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Color(kGenchiGreen),
              height: MediaQuery.of(context).size.height*0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "WHAT BRINGS YOU TO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(kGenchiCream),
                      fontSize: 40.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.05,
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Hero(
                      tag: 'logo',
                      child: Container(
                        child: Image.asset('images/LogoAndName.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width*0.425,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
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
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("Hire",
                                  style: TextStyle(
                                    color: Color(kGenchiBlue),
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
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
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.05,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.425,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
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
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("Provide",
                                  style: TextStyle(
                                    color: Color(kGenchiOrange),
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
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
                  ),

                ],
              )
            ),

          ],
        ),
      ),
    );
  }
}
