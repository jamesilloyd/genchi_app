import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/models/provider.dart';
import 'chat_screen.dart';
import 'package:genchi_app/components/message_list_item.dart';

import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:provider/provider.dart';

//TODO: create function that streams chats associated with the userid
//TODO: for each chat fetch the other user's data and display

class ChatSummaryScreen extends StatefulWidget {
  @override
  _ChatSummaryScreenState createState() => _ChatSummaryScreenState();
}

class _ChatSummaryScreenState extends State<ChatSummaryScreen> {

  FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  //ToDo: this can all go into CRUDModel
  Future<Map<Chat , ProviderUser>> getUserChatsAndProviders(chatIds) async {

    Map<Chat,ProviderUser> chatAndProviders = {};
    List<Chat> chats = [];
    for (String chatId in chatIds) {
      chats.add(await firestoreAPI.getChatById(chatId));
    }
    for(Chat chat in chats){
      ProviderUser provider = await firestoreAPI.getProviderById(chat.pid);
      chatAndProviders[chat] = provider;
    }
    return chatAndProviders;
  }

  //ToDo: this can all go into CRUDModel
  Future<List<ProviderUser>> getUsersProviders(usersPids) async {
    List<ProviderUser> providers = [];
    for (var pid in usersPids) {
      providers.add(await firestoreAPI.getProviderById(pid));
    }
    return providers;
  }

  @override
  Widget build(BuildContext context) {
    print('Chat screen activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;
    print(currentUser.chats);

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Messages"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            Center(
              child: Text("Your Hirer Chats"),
            ),
            FutureBuilder(
              future: getUserChatsAndProviders(currentUser.chats),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  //ToDo: Add in progressmodalhud
                  return Center(child: Text("Loading Chats"));
                }

                final Map<Chat,ProviderUser> chatsAndProviders = snapshot.data;
                print(chatsAndProviders);

                List<MessageListItem> chatWidgets = [];

                //Todo: firstly we need to fetch both their provider data from the firestore
                //Todo: now from the chats we need to work out which belong to the user (simple if (chat's uid = currentuser.uid))

                chatsAndProviders.forEach((k,v){
                  print('${k.pid} ${v.pid}');
                });

//                for (ProviderUser provider in chatsAndProviders.values) {
//                  MessageListItem chatWidget = MessageListItem(
//                    //ToDo: implement dp
//                    image: AssetImage("images/Logo_Clear.png"),
//                    name: "Leroy",
//                    lastMessage: "Hey dude",
//                    time: "19:27 PM",
//                    hasUnreadMessage: true,
//                    newMesssageCount: 5,
//                    onTap: () {
//                      Navigator.pushNamed(context, ChatScreen.id);
//                    },
//                    service: "Photographer",
//                  );
//                }

                return Center(child: Text("Complete"));
              },
            ),
            Center(
              child: Text("Your Hirer Chats"),
            ),
          ],
        ),
      ),
    );
  }
}
