import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/rounded_button.dart';

import 'edit_provider_account_screen.dart';
import 'chat_screen.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderScreen extends StatefulWidget {
  static const String id = "provider_screen";
  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {


  FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();
  bool isFavourite = false;


  @override
  Widget build(BuildContext context) {

    final ProviderScreenArguments args = ModalRoute.of(context).settings.arguments;
//    ProviderUser provider = args.provider;

    final authProvider = Provider.of<AuthenticationService>(context);
    final providerService = Provider.of<ProviderService>(context);


    ProviderUser providerUser = providerService.currentProvider;
    bool isUsersProviderProfile = authProvider.currentUser.providerProfiles.contains(providerUser.pid);
    isFavourite = authProvider.currentUser.favourites.contains(providerUser.pid);
    print(isFavourite);

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
              DisplayPicture(imageUrl: providerUser.displayPictureURL,height: 0.2,),
              SizedBox(height: 10),
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
                   onPressed: isUsersProviderProfile ? (){
                     Navigator.pushNamed(context, EditProviderAccountScreen.id, arguments: EditProviderAccountScreenArguments(provider: providerUser));
                   }: () async{

                     List userChats = authProvider.currentUser.chats;
                     if(kDebugMode) print('Provider Screen: User Chats = $userChats');
                     List providerChats = providerUser.chats;
                     if(kDebugMode) print('Provider Screen: Provider Chats = $providerChats');
                     List allChats = [userChats,providerChats];

                     final commonChatIds = allChats.fold<Set>(allChats.first.toSet(), (a, b) => a.intersection(b.toSet()));

                     if(kDebugMode) print('Provider Screen: Common Chats = $commonChatIds');

                     if(commonChatIds.isEmpty) {
                       print("Empty");
                       Navigator.pushNamed(context, ChatScreen.id,arguments: ChatScreenArguments(chat: Chat(),provider: providerUser,user: authProvider.currentUser, isFirstInstance: true));
                     } else {
                       //This is an existing chat
                       Chat existingChat = await firestoreAPI.getChatById(commonChatIds.first);
                       Navigator.pushNamed(context, ChatScreen.id,arguments: ChatScreenArguments(chat: existingChat,provider: providerUser,user: authProvider.currentUser));
                     }
                   },
                 )
               ),
              if(!isUsersProviderProfile)Align(
                alignment: Alignment.center,
                child: RoundedButton(
                  buttonColor: isFavourite ? Color(kGenchiGreen) : Color(kGenchiBlue),
                  fontColor: Color(kGenchiCream),
                  buttonTitle: isFavourite ? 'Added to Favourites': 'Add to Favourites',
                  onPressed: () async {
//                    setState(() {
//                      //TODO: may need to add in circular progress bar
//                    });
                    isFavourite ? firestoreAPI.removeUserFavourite(uid: authProvider.currentUser.id, favouritePid: providerUser.pid) : firestoreAPI.addUserFavourite(uid: authProvider.currentUser.id, favouritePid: providerUser.pid);
                    await authProvider.updateCurrentUserData();
                    setState((){});
                  },
                ),
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
                  fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "About Me",
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
                  fontWeight: FontWeight.w500,
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
                providerUser.experience ?? "",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Text(
                  "Pricing",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                    fontSize: 25.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                providerUser.pricing,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
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
