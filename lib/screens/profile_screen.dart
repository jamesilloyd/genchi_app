import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'profile_screen2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';

User currentUser;

class ProfileScreen extends StatefulWidget {

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  io.File _image;
  String userName;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        _image = image;
      },
    );
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        userName = loggedInUser.displayName;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<FirebaseCRUDModel>(context);
    final authProvider = Provider.of<AuthenticationService>(context);
//    User user = profileProvider.getUserById(widget.profileId);

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Profile"),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height - 168),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(20),
                    height: 250,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage("images/Logo_Clear.png"),
                                backgroundColor: Colors.white,
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 68, right: 20),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            '129',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('posts')
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 20),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            '129K',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('followers')
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 20),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            '129',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('following')
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: Colors.blue,
                                      ),
                                      margin: EdgeInsets.all(10),
                                      width: 120,
                                      height: 30,
                                      child: FlatButton(
                                        child: Text(
                                          'Add Photo',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          getImage();
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      height: 30,
                                      width: 120,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          border: Border.all(
                                              width: 1,
                                              color: Color(0xFFE7E7E7))),
                                      child: FlatButton(
                                        child: Text('Edit Profile'),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, SecondProfileScreen.id);
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  //Gram name from current user
                                  authProvider.currentUser.name??'',
//                                  userName == null ? "..." : userName,
//                                      profileData.name,
                                  style: TextStyle(
                                      fontFamily: 'Gotham',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                Text(
                                  authProvider.currentUser.bio ?? ' ',
                                ),
                              ],
                            ),
                            Container()
                          ],
                        )
                      ],
                    ),
                    color: Colors.white,
                  ),
                  Center(
                    child: Container(
                        margin: EdgeInsets.all(20),
                        child: _image == null
                            ? Center(child: Text('No image selected.'))
                            : Center(child: Image.file(_image))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
