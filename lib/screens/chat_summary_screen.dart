import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';

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

class _ChatSummaryScreenState extends State<ChatSummaryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();

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

  String filter = 'ALL';

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/home/chat_summary_screen");
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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: BasicAppNavigationBar(
          barTitle: 'Private Messages',
        ),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              if (userIsProvider)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                          height: 50,
                          child: PopupMenuButton(
                              elevation: 1,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      filter,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(width: 5),
                                    ImageIcon(
                                      AssetImage('images/filter.png'),
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    )
                                  ]),
                              itemBuilder: (_) => <PopupMenuItem<String>>[
                                    const PopupMenuItem<String>(
                                        child: const Text('ALL'), value: 'ALL'),
                                    const PopupMenuItem<String>(
                                        child: const Text('HIRING'),
                                        value: 'HIRING'),
                                    const PopupMenuItem<String>(
                                        child: const Text('PROVIDING'),
                                        value: 'PROVIDING'),
                                  ],
                              onSelected: (value) {
                                setState(() {
                                  filter = value;
                                });
                              })),
                    ],
                  ),
                ),
              Divider(
                height: 0,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              StreamBuilder(
                stream: firestoreAPI.streamUserChats(user: currentUser),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      height: 60,
                      child: Center(
                        child: CircularProgress(),
                      ),
                    );
                  } else {
                    List chatsHirersAndProviders = [];
                    List<Widget> chatWidgets = [];

                    if (userIsProvider) {
                      ///Receiving chats for hiring and providing
                      List list1 = snapshot.data[0];
                      List list2 = snapshot.data[1];
                      chatsHirersAndProviders.addAll(list1);
                      chatsHirersAndProviders.addAll(list2);

                      chatsHirersAndProviders.sort((a, b) {
                        if (a != null && b != null) {
                          Chat chatA = a['chat'];
                          Chat chatB = b['chat'];
                          return chatB.time.compareTo(chatA.time);
                        } else
                          return b.toString().compareTo(a.toString());
                      });
                    } else {
                      ///Only receiving chats for hiring
                      chatsHirersAndProviders = snapshot.data;
                    }

                    for (Map chatHirerAndProvider in chatsHirersAndProviders) {
                      if (chatHirerAndProvider != null) {
                        Chat chat = chatHirerAndProvider['chat'];
                        ProviderUser provider =
                            chatHirerAndProvider['provider'];
                        User hirer = chatHirerAndProvider['hirer'];
                        bool userChatIsProvider =
                            chatHirerAndProvider['userIsProvider'];

                        if (userChatIsProvider &&
                            (filter == 'ALL' || filter == 'PROVIDING')) {
                          ///Users providing messages
                          Widget chatWidget = MessageListItem(
                            image: hirer.displayPictureURL == null
                                ? null
                                : CachedNetworkImageProvider(
                                    hirer.displayPictureURL),
                            name: hirer.name,
                            service: provider.type,
                            lastMessage: chat.lastMessage,
                            time: chat.time,
                            hasUnreadMessage: chat.providerHasUnreadMessage,
                            type: 'PROVIDING',
                            deleteMessage: 'Archive',
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
                              bool deleteChat = await showYesNoAlert(
                                  context: context,
                                  title: "Are you sure you want delete chat?");

                              if (deleteChat) {
                                setState(() {
                                  showSpinner = true;
                                });
                                await analytics.logEvent(
                                    name: 'provider_hidden_chat');
                                await firestoreAPI.hideChat(
                                    chat: chat, forProvider: true);

                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            },
                          );

                          if (!chat.isHiddenFromProvider)
                            chatWidgets.add(chatWidget);
                        } else if (!userChatIsProvider &&
                            (filter == 'ALL' || filter == 'HIRING')) {
                          ///Users hiring messages
                          Widget chatWidget = MessageListItem(
                            image: provider.displayPictureURL == null
                                ? null
                                : CachedNetworkImageProvider(
                                    provider.displayPictureURL),
                            name: provider.name,
                            service: provider.type,
                            lastMessage: chat.lastMessage,
                            time: chat.time,
                            type: 'HIRING',
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
                                  title: "Are you sure you want delete chat?");
                              if (deleteChat) {
                                setState(() {
                                  showSpinner = true;
                                });
                                await analytics.logEvent(
                                    name: 'hirer_hidden_chat');
                                await firestoreAPI.hideChat(
                                    chat: chat, forProvider: false);
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            },
                          );

                          if (!chat.isHiddenFromUser)
                            chatWidgets.add(chatWidget);
                        }
                      }
                    }

                    if (chatsHirersAndProviders.isEmpty | chatWidgets.isEmpty) {
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

                    print('REBUILDING');
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: chatWidgets,
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
