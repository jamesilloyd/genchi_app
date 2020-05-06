import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'edit_provider_account_screen.dart';

class ProviderScreen extends StatefulWidget {
  static const String id = "provider_screen";
  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {

  bool isUsersProviderProfile = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppNavigationBar(
        barTitle: isUsersProviderProfile ? "Your Provider Name" : "Provider's Name",
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                height: MediaQuery.of(context).size.height * 0.2,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Center(
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage("images/Logo_Clear.png"),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                child: Text(
                  "Your Provider Name",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: RoundedButton(
                  buttonColor: isUsersProviderProfile ?  Color(kGenchiGreen) : Color(kGenchiOrange),
                  buttonTitle: isUsersProviderProfile ? 'Edit Provider Profile' : 'Message',
                  fontColor: isUsersProviderProfile ?  Colors.white : Color(kGenchiBlue),
                  onPressed: (){
                    Navigator.pushNamed(context, EditProviderAccountScreen.id);
                  },
                )
              ),
              Divider(),
              Container(
                child: Text(
                  "Service",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'Barber',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "Experience",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                  'Been cutting hair since I was 3 years old. Been cutting hair since I was 3 years old. Been cutting hair since I was 3 years old. Been cutting hair since I was 3 years old. Been cutting hair since I was 3 years old.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),


    );
  }
}
