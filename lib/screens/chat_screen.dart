import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/chat_message_bubble.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/chat.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/provider_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  final TextEditingController messageTextController = TextEditingController();

  String messageText;

  Chat thisChat;
  bool userIsProvider;
  ProviderUser provider;
  User user;
  bool isFirstInstance;
  bool showSpinner = false;

  @override
  void dispose() {
    super.dispose();
    messageTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    final providerService = Provider.of<ProviderService>(context);

    final ChatScreenArguments args = ModalRoute.of(context).settings.arguments;
    userIsProvider = args.userIsProvider;
    if (thisChat == null) thisChat = args.chat;
    provider = args.provider;
    user = args.user;
    if (isFirstInstance == null) isFirstInstance = args.isFirstInstance;
    if (kDebugMode) print('Chat Screen: thisChat.id is ${thisChat.chatid}');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: ChatNavigationBar(
          barTitle: userIsProvider ? user.name : provider.name,
          provider: provider,
          imageURL: userIsProvider
              ? user.displayPictureURL
              : provider.displayPictureURL,
          userIsProvider: userIsProvider,
        ),
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: showSpinner,
            progressIndicator: CircularProgress(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                  stream: firestoreAPI.fetchChatStream(thisChat.chatid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgress();
                    }

                    final messages = snapshot.data.documents;
                    List<MessageBubble> messageBubbles = [];
                    for (var message in messages) {
                      final messageText = message.data['text'];
                      final messageSender = message.data['sender'];
                      final messageTime = message.data['time'];

                      final messageWidget = MessageBubble(
                        text: messageText,
                        sender: messageSender,
                        isMe: userIsProvider
                            ? messageSender == provider.pid
                            : messageSender == user.id,
                        time: messageTime,
                      );
                      messageBubbles.add(messageWidget);
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
                        children: messageBubbles,
                      ),
                    );
                  },
                ),
                Container(
                  decoration: kMessageContainerDecoration,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          minLines: 1,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          controller: messageTextController,
                          onChanged: (value) {
                            messageText = value;
                          },
                          cursorColor: Color(kGenchiOrange),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: kMessageTextFieldDecoration,
                        ),
                      ),
                      FlatButton(
                        onPressed: () async {
                          setState(() {});
                          if (messageText != null) {
                            if (isFirstInstance) {
                              if (debugMode)
                                print(
                                    'Chat screen: message text is not null and this is the first instance so creating new chat ');
                              setState(() {
                                messageTextController.clear();
                                showSpinner = true;
                              });

                              DocumentReference result =
                                  await firestoreAPI.addNewChat(
                                uid: authProvider.currentUser.id,
                                pid: provider.pid,
                              );
                              await authProvider.updateCurrentUserData();
                              await providerService
                                  .updateCurrentProvider(provider.pid);

                              thisChat = await firestoreAPI
                                  .getChatById(result.documentID);

                              ///Just check that the chat definitely exists before adding a message to it
                              if (thisChat != null) {
                                await firestoreAPI.addMessageToChat(
                                    chatId: thisChat.chatid,
                                    chatMessage: ChatMessage(
                                        sender: userIsProvider
                                            ? provider.pid
                                            : user.id,
                                        text: messageText,
                                        time: Timestamp.now()),
                                    providerIsSender:
                                        userIsProvider ? true : false);

                                setState(() {
                                  isFirstInstance = false;
                                  showSpinner = false;
                                });
                              }
                            } else {
                              if (debugMode)
                                print(
                                    'Chat screen: Message text is not null and this is NOT the first instance');
//                                      messageText = messageTextController.text;
                              setState(() => messageTextController.clear());
                              await firestoreAPI.addMessageToChat(
                                  chatId: thisChat.chatid,
                                  chatMessage: ChatMessage(
                                      sender: userIsProvider
                                          ? provider.pid
                                          : user.id,
                                      text: messageText,
                                      time: Timestamp.now()),
                                  providerIsSender:
                                      userIsProvider ? true : false);
                            }
                          } else {
                            if (debugMode)
                              print('Chat screen: Message text is null');
                          }
                        },
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Color(kGenchiOrange),
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
