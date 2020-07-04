import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/screen_arguments.dart';

import 'package:provider/provider.dart';

class ChatSummaryScreen extends StatefulWidget {
  @override
  _ChatSummaryScreenState createState() => _ChatSummaryScreenState();
}


class _ChatSummaryScreenState extends State<ChatSummaryScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;


  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;

  Future<List<Map<String, dynamic>>> buildUserChatSummary(
      {QuerySnapshot chats}) async {
    List<Map<String, dynamic>> chatsAndProviders = [];

    for (DocumentSnapshot doc in chats.documents) {
      Chat chat = Chat.fromMap(doc.data);
      ProviderUser provider = await firestoreAPI.getProviderById(chat.pid);

      if (provider != null) {
        chatsAndProviders.add({'chat': chat, 'provider': provider});
      }
    }

    return chatsAndProviders;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('Chat summary screen activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    User currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: CircularProgress(),
      child: DefaultTabController(
        length: userIsProvider ? 2 : 1,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              title: Text(
                'Private Messages',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Color(kGenchiGreen),
              elevation: 2.0,
              brightness: Brightness.light,
              bottom: TabBar(
                  indicatorColor: Color(kGenchiOrange),
                  labelColor: Colors.black,
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontFamily: 'FuturaPT',
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: 'Hiring'),
                    if (userIsProvider) Tab(text: 'Providing'),
                  ])),
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
                      thickness: 1,
                    ),
                    StreamBuilder(
                      stream: firestoreAPI.streamUserChatsAndProviders(
                          userId: currentUser.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgress();
                        } else {
                          List<Map<String, dynamic>> chatsAndProviders = snapshot.data;
                          List<Widget> widgets = [];

                          for (Map<String, dynamic> chatAndProvder in chatsAndProviders) {
                            if(chatAndProvder!=null) {
                              Chat chat = chatAndProvder['chat'];
                              ProviderUser provider = chatAndProvder['provider'];

                              MessageListItem chatWidget = MessageListItem(
                                image: provider.displayPictureURL == null
                                    ? AssetImage("images/Logo_Clear.png")
                                    : CachedNetworkImageProvider(
                                    provider.displayPictureURL),
                                name: provider.name,
                                service: provider.type,
                                lastMessage: chat.lastMessage,
                                time: chat.time,
                                hasUnreadMessage: chat.userHasUnreadMessage,
                                onTap: () async {
                                  setState(() {
                                    showSpinner = true;
                                  });
                                  chat.userHasUnreadMessage = false;
                                  await firestoreAPI.updateChat(chat: chat);

                                  setState(() {
                                    showSpinner = false;
                                  });
                                  Navigator.pushNamed(context, ChatScreen.id,
                                      arguments: ChatScreenArguments(
                                          chat: chat,
                                          userIsProvider: false,
                                          provider: provider,
                                          user: currentUser,
                                          isFirstInstance: false));
                                },
                                hideChat: () async {
                                  bool deleteChat = await showYesNoAlert(
                                      context: context,
                                      title:
                                      "Are you sure you want delete chat?");
                                  if (deleteChat)
                                    await firestoreAPI.hideChat(
                                        chat: chat, forProvider: false);
                                  if (deleteChat) setState(() {});
                                },
                              );

                              if (!chat.isHiddenFromUser) widgets.add(
                                  chatWidget);
                            }
                          }

                          if (chatsAndProviders.isEmpty | widgets.isEmpty) {
                            return Container(
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
                          }

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widgets,
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
              if (userIsProvider)
                SafeArea(
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
                            thickness: 1,
                          ),
                          StreamBuilder(
                            stream: firestoreAPI.streamUserProviderChatsAndHirers(
                                userPids: currentUser.providerProfiles),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgress();
                              }

                              final List<Map<String, dynamic>>
                                  userProviderChatsAndUsers = snapshot.data;

                              List<MessageListItem> chatWidgets = [];

                              for (Map providerChatAndUser
                                  in userProviderChatsAndUsers) {
                                Chat chat = providerChatAndUser['chat'];
                                ProviderUser provider =
                                    providerChatAndUser['provider'];
                                User hirer = providerChatAndUser['hirer'];

                                MessageListItem chatWidget = MessageListItem(
                                  image: hirer.displayPictureURL == null
                                      ? AssetImage("images/Logo_Clear.png")
                                      : CachedNetworkImageProvider(
                                          hirer.displayPictureURL),
                                  name: hirer.name,
                                  service: provider.type,
                                  lastMessage: chat.lastMessage,
                                  time: chat.time,
                                  hasUnreadMessage:
                                      chat.providerHasUnreadMessage,
                                  onTap: () async {
                                    setState(() {
                                      showSpinner = true;
                                    });
                                    chat.providerHasUnreadMessage = false;
                                    await firestoreAPI.updateChat(chat: chat);

                                    setState(() {
                                      showSpinner = false;
                                    });
                                    Navigator.pushNamed(context, ChatScreen.id,
                                            arguments: ChatScreenArguments(
                                                chat: chat,
                                                userIsProvider: true,
                                                provider: provider,
                                                user: hirer));

                                  },
                                  hideChat: () async {
                                    //TODO: probably need to change this so that we selectively choose which chats "where hide = false"
                                    bool deleteChat = await showYesNoAlert(
                                        context: context,
                                        title:
                                            "Are you sure you want delete chat?");
                                    setState(() {
                                      showSpinner = true;
                                    });

                                    if (deleteChat)
                                      await firestoreAPI.hideChat(
                                          chat: chat, forProvider: true);

                                    setState(() {
                                      showSpinner = false;
                                    });
                                  },
                                );

                                if (!chat.isHiddenFromProvider)
                                  chatWidgets.add(chatWidget);
                              }

                              if (userProviderChatsAndUsers.isEmpty |
                                  chatWidgets.isEmpty) {
                                return Container(
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
                              }

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
      ),
    );
  }
}
