import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'profile_screen2.dart';
import 'welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  io.File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState( () {
        _image = image;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
        routes: {
          SecondProfileScreen.id: (context) => SecondProfileScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
        },
        builder: (context) {
          return Scaffold(
            appBar: AppNavigationBar(barTitle: "Profile"),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RoundedButton(
                        buttonColor: Colors.blueAccent,
                        buttonTitle: "Screen 2",
                        onPressed: () {
                          Navigator.pushNamed(context, SecondProfileScreen.id);
                        },
                      ),
                    ],
                  ),
                  RoundedButton(
                    buttonColor: Colors.redAccent,
                    buttonTitle: "Add image",
                    onPressed: () {
                      getImage();
                    },
                  ),
                  _image == null
                      ? Center(child: Text('No image selected.'))
                      : Center(child: Image.file(_image)),
                ],
              ),
            ),
          );
        });
  }
}
