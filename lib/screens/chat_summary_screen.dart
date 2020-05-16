import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

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

  @override
  Widget build(BuildContext context) {
    print('Chat screen activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return DefaultTabController(
      length: userIsProvider ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Color(kGenchiBlue),
          ),
          title: Text(
            'Messages',
            style: TextStyle(
              color: Color(kGenchiBlue),
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Color(kGenchiCream),
          elevation: 2.0,
          brightness: Brightness.light,
          bottom: TabBar(
            labelColor: Color(kGenchiBlue),
            labelStyle: TextStyle(
              fontSize: 20,
              fontFamily: 'FuturaPT',
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'Hiring'),
              if(userIsProvider) Tab(text: 'Providing'),
            ]
          )
        ),
        body: TabBarView(
          children: <Widget>[
            SafeArea(
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
                  //TODO: this must be changed to streambuilder
                  FutureBuilder(
                    future: firestoreAPI.getUserChatsAndProviders(chatIds: currentUser.chats),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgress();
                      }

                      //ToDo: if you have no messages display some feedback
                      final Map<Chat, ProviderUser> chatsAndProviders = snapshot.data;

                      if(chatsAndProviders.isEmpty){
                       return  Container(
                         height: 30,
                         child: Center(
                           child: Text(
                             'No Messages',
                             style: TextStyle(
                               fontSize: 20,
                             ),
                           ),
                         ),
                       );
                      };

                      List<MessageListItem> chatWidgets = [];

                      chatsAndProviders.forEach(
                            (k, v) {

                          Chat chat = k;
                          ProviderUser provider = v;

                          MessageListItem chatWidget = MessageListItem(
                            image: provider.displayPictureURL == null ? AssetImage("images/Logo_Clear.png") : CachedNetworkImageProvider(provider.displayPictureURL),
                            name: provider.name,
                            service: provider.type,
                            lastMessage: chat.lastMessage,
                            time: chat.time,
                            hasUnreadMessage: chat.userHasUnreadMessage,
                            onTap: () async {
                              chat.userHasUnreadMessage = false;
                              await firestoreAPI.updateChat(chat: chat);
                              Navigator.pushNamed(context, ChatScreen.id,arguments: ChatScreenArguments(chat: chat, userIsProvider: false,provider: provider,user: currentUser, isFirstInstance: false));
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
                ],
              ),
            ),
            if(userIsProvider) SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: <Widget>[
                  Column(
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
                        future: firestoreAPI.getUserProviderChatsAndUsers(usersPids: currentUser.providerProfiles),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgress();
                          }

                          final Map<ProviderUser, Map<Chat, User>>
                          userProviderChatsAndUsers = snapshot.data;


                          if(userProviderChatsAndUsers.isEmpty){
                            return  Container(
                              height: 30,
                              child: Center(
                                child: Text(
                                  'No Messages',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            );
                          };


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
                                    image: user.displayPictureURL == null ? AssetImage("images/Logo_Clear.png") : CachedNetworkImageProvider(user.displayPictureURL),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
