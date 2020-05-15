import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'chat_screen.dart';

import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/authentication.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/screen_arguments.dart';

import 'package:provider/provider.dart';

class ChatSummaryScreen extends StatefulWidget {
  @override
  _ChatSummaryScreenState createState() => _ChatSummaryScreenState();
}

class _ChatSummaryScreenState extends State<ChatSummaryScreen> {
  FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  //ToDo: this can all go into CRUDModel
  Future<Map<Chat, ProviderUser>> getUserChatsAndProviders(chatIds) async {
    Map<Chat, ProviderUser> chatAndProviders = {};
    List<Chat> chats = [];
    for (String chatId in chatIds) {
      Chat chat = await firestoreAPI.getChatById(chatId);
      chats.add(chat);
    }

    chats.sort((a,b) => b.time.compareTo(a.time));
    for (Chat chat in chats) {
      ProviderUser provider = await firestoreAPI.getProviderById(chat.pid);
      chatAndProviders[chat] = provider;
    }
    return chatAndProviders;
  }

  //ToDo: this can all go into CRUDModel
  Future<Map<ProviderUser, Map<Chat, User>>> getUserProviderChatsAndUsers(usersPids) async {
    Map<ProviderUser, Map<Chat, User>> userProviderChatsAndUsers = {};

    List<ProviderUser> providers = [];

    for (String pid in usersPids) {

      List<Chat> chats = [];
      Map<Chat, User> chatsAndUsers = {};

      ProviderUser provider = await firestoreAPI.getProviderById(pid);

      if(provider.chats.isNotEmpty) {

        for (String chatId in provider.chats) {
          Chat chat = await firestoreAPI.getChatById(chatId);
          chats.add(chat);
        }

        chats.sort((a,b) => b.time.compareTo(a.time));

        for (Chat chat in chats) {
          User chatUser = await firestoreAPI.getUserById(chat.uid);
          chatsAndUsers[chat] = chatUser;
        }
        userProviderChatsAndUsers[provider] = chatsAndUsers;
      }

    }

    return userProviderChatsAndUsers;
  }



  @override
  Widget build(BuildContext context) {
    print('Chat screen activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Messages"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            Container(
              height: 50,
              child: Center(
                child: Text(
                  'Your Hiring Messages',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(kGenchiBlue),
                    fontWeight: FontWeight.w400,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
            Divider(
              height: 0,
            ),
            FutureBuilder(
              future: getUserChatsAndProviders(currentUser.chats),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgress();
                }

                //ToDo: if you have no messages display some feedback
                final Map<Chat, ProviderUser> chatsAndProviders = snapshot.data;

                List<MessageListItem> chatWidgets = [];

                chatsAndProviders.forEach(
                  (k, v) {

                    Chat chat = k;
                    ProviderUser provider = v;

                    MessageListItem chatWidget = MessageListItem(
                      //ToDo: implement dp
                      image: AssetImage("images/Logo_Clear.png"),
                      name: provider.name,
                      service: provider.type,
                      lastMessage: chat.lastMessage,
                      time: chat.time,
                      hasUnreadMessage: chat.userHasUnreadMessage,
                      onTap: () async {
                        chat.userHasUnreadMessage = false;
                        await firestoreAPI.updateChat(chat: chat);
                        Navigator.pushNamed(context, ChatScreen.id,arguments: ChatScreenArguments(chat: chat, userIsProvider: false,provider: provider,user: currentUser));
                      },
                    );

                    chatWidgets.add(chatWidget);
                  },
                );

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: chatWidgets,
                );
              },
            ),

            userIsProvider ? Column(
              children: <Widget>[
                Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      'Your Providing Messages',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(kGenchiBlue),
                        fontWeight: FontWeight.w400,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 0,
                ),
                FutureBuilder(
                  future: getUserProviderChatsAndUsers(currentUser.providerProfiles),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgress();
                    }

                    final Map<ProviderUser, Map<Chat, User>>
                        userProviderChatsAndUsers = snapshot.data;


                    List<MessageListItem> chatWidgets = [];

                    userProviderChatsAndUsers.forEach(
                      (k, v) {
                        ProviderUser provider = k;

                        Map<Chat, User> chatsAndUsers = v;

                        chatsAndUsers.forEach(
                          (k, v) {
                            Chat chat = k;
                            User user = v;

                            MessageListItem chatWidget = MessageListItem(
                              //ToDo: implement dp
                              image: AssetImage("images/Logo_Clear.png"),
                              name: user.name,
                              service: provider.type,
                              lastMessage: chat.lastMessage,
                              time: chat.time,
                              hasUnreadMessage: chat.providerHasUnreadMessage,
                              onTap: () async {
                                chat.providerHasUnreadMessage = false;
                                await firestoreAPI.updateChat(chat: chat);
                                Navigator.pushNamed(context, ChatScreen.id,arguments: ChatScreenArguments(chat: chat, userIsProvider: true, provider: provider, user: user));
                              },
                            );

                            chatWidgets.add(chatWidget);
                          },
                        );
                      },
                    );

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: chatWidgets,
                    );
                  },
                ),
              ],
            ) : SizedBox(),
          ],
        ),
      ),
    );
  }
}
