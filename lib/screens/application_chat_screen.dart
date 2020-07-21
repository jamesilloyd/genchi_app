import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/chat_message_bubble.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/task.dart';
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

class ApplicationChatScreen extends StatefulWidget {
  static const String id = "application_chat_screen";

  @override
  _ApplicationChatScreenState createState() => _ApplicationChatScreenState();
}

class _ApplicationChatScreenState extends State<ApplicationChatScreen> {
  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  final TextEditingController messageTextController = TextEditingController();

  String messageText;

  TaskApplicant thisTaskApplicant;
  bool userIsProvider;
  ProviderUser provider;
  User hirer;

  bool showSpinner = false;

  @override
  void dispose() {
    super.dispose();
    messageTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final ApplicationChatScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    thisTaskApplicant = args.taskApplicant;
    userIsProvider = args.userIsProvider;

    provider = args.provider;
    hirer = args.hirer;

    if (kDebugMode)
      print(
          'Application Chat Screen: this applicationid is ${thisTaskApplicant.applicationId}');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: ChatNavigationBar(
          hirer: hirer,
          provider: provider,
          imageURL: userIsProvider
              ? hirer.displayPictureURL
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
                  stream: firestoreAPI.fetchTaskApplicantChatStream(
                      taskid: thisTaskApplicant.taskid,
                      applicantId: thisTaskApplicant.applicationId),
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
                            : messageSender == hirer.id,
                        time: messageTime,
                      );
                      messageBubbles.add(messageWidget);
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20.0),
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
                          if (messageText != null) {
                            if (debugMode)
                              print(
                                  'Chat screen: Message text is not null and this is NOT the first instance');
                            setState(() => messageTextController.clear());

                            await firestoreAPI.addMessageToTaskApplicant(
                                applicantId: thisTaskApplicant.applicationId,
                                taskId: thisTaskApplicant.taskid,
                                chatMessage: ChatMessage(
                                    sender: userIsProvider
                                        ? provider.pid
                                        : hirer.id,
                                    text: messageText,
                                    time: Timestamp.now()),
                                providerIsSender: userIsProvider);
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
