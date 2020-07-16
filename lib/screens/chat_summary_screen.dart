import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';

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

  String filter = 'All';

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
            padding: const EdgeInsets.all(10.0),
            children: <Widget>[
              if(userIsProvider) Container(
                  height: 50,
                  child: PopupMenuButton(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(filter),
                            SizedBox(width: 5),
                            Icon(
                              Icons.filter_list,
                              color: Color(kGenchiBlue),
                            ),
                            SizedBox(
                              width: 5,
                            )
                          ]),
                      itemBuilder: (_) => <PopupMenuItem<String>>[
                            new PopupMenuItem<String>(
                                child: const Text('All'), value: 'All'),
                            new PopupMenuItem<String>(
                                child: const Text('Hiring'),
                                value: 'Hiring'),
                            new PopupMenuItem<String>(
                                child: const Text('Providing'),
                                value: 'Providing'),
                          ],
                      onSelected: (value) {
                        setState(() {
                          filter = value;
                        });
                      })),
              Divider(
                height: 0,
                thickness: 1,
              ),
              StreamBuilder(
                stream: firestoreAPI.streamUserChats(user: currentUser),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgress();
                  } else {
                    List chatsHirersAndProviders = [];

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

                    List<Widget> chatWidgets = [];

                    for (Map chatHirerAndProvider in chatsHirersAndProviders) {
                      if (chatHirerAndProvider != null) {
                        Chat chat = chatHirerAndProvider['chat'];
                        ProviderUser provider =
                            chatHirerAndProvider['provider'];
                        User hirer = chatHirerAndProvider['hirer'];
                        bool userIsProvider =
                            chatHirerAndProvider['userIsProvider'];

                        if (userIsProvider &&
                            (filter == 'All' || filter == 'Providing')) {
                          ///Users providing messages
                          MessageListItem chatWidget = MessageListItem(
                            image: hirer.displayPictureURL == null
                                ? null
                                : CachedNetworkImageProvider(
                                    hirer.displayPictureURL),
                            name: hirer.name,
                            service: provider.type,
                            lastMessage: chat.lastMessage,
                            time: chat.time,
                            hasUnreadMessage: chat.providerHasUnreadMessage,
                            isHiring: false,
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
                                  title: "Are you sure you want delete chat?");

                              if (deleteChat) {
                                await firestoreAPI.hideChat(
                                    chat: chat, forProvider: true);
                              }
                            },
                          );

                          if (!chat.isHiddenFromProvider)
                            chatWidgets.add(chatWidget);
                        } else if (!userIsProvider &&
                            (filter == 'All' || filter == 'Hiring')) {
                          ///Users hiring messages
                          MessageListItem chatWidget = MessageListItem(
                            image: provider.displayPictureURL == null
                                ? null
                                : CachedNetworkImageProvider(
                                    provider.displayPictureURL),
                            name: provider.name,
                            service: provider.type,
                            lastMessage: chat.lastMessage,
                            time: chat.time,
                            isHiring: true,
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
                                await firestoreAPI.hideChat(
                                    chat: chat, forProvider: false);
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
