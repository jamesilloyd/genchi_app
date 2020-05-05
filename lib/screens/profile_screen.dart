import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:provider/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'dart:io' show Platform;
import 'package:genchi_app/components/platform_alerts.dart';
import 'welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';


User currentUser;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  static const GenchiURL = 'https://www.genchi.app';

  io.File _image;
  String userName;
  List<ProviderUser> providers;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        _image = image;
      },
    );
  }

//  Future<List<ProviderCard>> getUserProviders(
//      List<String> pids, FirestoreCRUDModel firestoreCRUDModel) async {
//    List<ProviderCard> providerCards;
//
//    for (String pid in pids) {
//      providerCards.add(ProviderCard(
//          providerDetails: await firestoreCRUDModel.getProviderById(pid)));
//    }
//
//    return providerCards;
//  }

  final FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: MyAppNavigationBar(
          barTitle: authProvider.currentUser.name ?? "Profile"),
      body: Container(
        color: Colors.white,
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                color: Color(kGenchiGreen),
                height: MediaQuery.of(context).size.height*0.2,
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
              Divider(
                height: 0,
              ),
              ProfileOptionTile(text: 'Create Provider Account',onPressed: (){}),
              ProfileOptionTile(text: 'Change Details',onPressed: (){}),
              ProfileOptionTile(text: 'About Genchi', onPressed: () async {
                if (await canLaunch(GenchiURL)) {
                  await launch(GenchiURL);
                } else {
                  print("Could not open URL");
                }
              }),
              ProfileOptionTile(text: 'Log Out', onPressed: () {
              Platform.isIOS
              ? showAlertIOS(context, () {
              authProvider.signUserOut();
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(WelcomeScreen.id,
              (Route<dynamic> route) => false);
              }, "Log out")
                  : showAlertAndroid(context, () {
              authProvider.signUserOut();
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(WelcomeScreen.id,
              (Route<dynamic> route) => false);
              }, "Log out");
              },
              ),
            ],
          ),
        ),
//        child: Container(
//          margin: EdgeInsets.all(20),
//          height: 250,
//          color: Colors.white,
//          child: Column(
//            children: <Widget>[
//              Row(
//                children: <Widget>[
//                  Container(
//                    height: 50,
//                    width: 50,
//                    child: CircleAvatar(
//                      backgroundImage: AssetImage("images/Logo_Clear.png"),
//                      backgroundColor: Colors.white,
//                    ),
//                  ),
//                  Row(
//                    children: <Widget>[
//                      Container(
//                        decoration: BoxDecoration(
//                          borderRadius: BorderRadius.all(Radius.circular(5)),
//                          color: Colors.blue,
//                        ),
//                        margin: EdgeInsets.all(10),
//                        width: 120,
//                        height: 30,
//                        child: FlatButton(
//                          child: Text(
//                            'Add Photo',
//                            style: TextStyle(color: Colors.white),
//                          ),
//                          onPressed: () {
//                            getImage();
//                          },
//                        ),
//                      ),
//                      Container(
//                        margin: EdgeInsets.all(10),
//                        height: 30,
//                        width: 120,
//                        decoration: BoxDecoration(
//                            borderRadius: BorderRadius.all(Radius.circular(5)),
//                            border:
//                                Border.all(width: 1, color: Color(0xFFE7E7E7))),
//                        child: FlatButton(
//                          child: Text('Edit Profile'),
//                          onPressed: () {
//                            Navigator.pushNamed(
//                                context, SecondProfileScreen.id);
//                          },
//                        ),
//                      ),
//                    ],
//                  )
//                ],
//              ),
//              Divider(),
////              StreamBuilder(
////                stream: firestoreAPI.fetchProvidersAsStream(),
////                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
////                  if (snapshot.hasData) {
////                    providers = snapshot.data.documents.map((doc) => ProviderUser.fromMap(doc.data)).toList();
////                    return Expanded(
////                      child: ListView.builder(
////                        itemCount: providers.length,
////                        itemBuilder: (buildContext, index) =>
////                            ProviderCard(providerDetails: providers[index]),
////                      ),
////                    );
////                  } else {
////                    return Text('fetching');
////                  }
////                },
////              ),
//              Column(
//                children: <Widget>[
////                  FutureBuilder(
////                    future: getUserProviders(authProvider.currentUser.providerProfiles, firestoreProvider),
////                    builder: (context, snapshot) {
//////                      List<Widget> children;
//////                      if(snapshot.hasData){
//////                        print(snapshot.data);
//////                      }
////
////                      return snapshot.data;
////                    },
////                  )
//                ],
//              )
//            ],
//          ),
//        ),
      ),
    );
  }
}

class ProfileOptionTile extends StatelessWidget {

  final String text;
  final Function onPressed;

  const ProfileOptionTile({this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 50,
          child: FlatButton(
            onPressed: onPressed,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                  text,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(kGenchiBlue),
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }
}
