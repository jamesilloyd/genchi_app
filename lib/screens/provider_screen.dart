import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';

import 'edit_provider_account_screen.dart';
import 'chat_screen.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/authentication.dart';

import 'package:provider/provider.dart';

class ProviderScreen extends StatefulWidget {
  static const String id = "provider_screen";
  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {

  FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();


  @override
  Widget build(BuildContext context) {

    final ProviderScreenArguments args = ModalRoute.of(context).settings.arguments;
//    ProviderUser provider = args.provider;

    final authProvider = Provider.of<AuthenticationService>(context);
    final providerService = Provider.of<ProviderService>(context);

    ProviderUser providerUser = providerService.currentProvider;
    print(providerUser.pid);
    bool isUsersProviderProfile = authProvider.currentUser.providerProfiles.contains(providerUser.pid);

    return Scaffold(
      appBar: MyAppNavigationBar(
        barTitle: providerUser.name ?? "",
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
                  providerUser.name ?? "",
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
                    //TODO: Either navigate to edit account or new message with provider, no need for fancy routing
                    isUsersProviderProfile ? Navigator.pushNamed(context, EditProviderAccountScreen.id, arguments: EditProviderAccountScreenArguments(provider: providerUser)) : Navigator.pushNamed(context, ChatScreen.id);
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
                providerUser.type ?? "",
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
                providerUser.bio ?? "",
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