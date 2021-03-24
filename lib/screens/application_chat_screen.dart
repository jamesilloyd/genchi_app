import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/chat_message_bubble.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/chat.dart';

import 'package:genchi_app/services/firestore_api_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ApplicationChatScreen extends StatefulWidget {
  static const String id = "application_chat_screen";

  @override
  _ApplicationChatScreenState createState() => _ApplicationChatScreenState();
}

class _ApplicationChatScreenState extends State<ApplicationChatScreen> {
  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  final TextEditingController messageTextController = TextEditingController();

  FirebaseAnalytics analytics = FirebaseAnalytics();

  String messageText;

  TaskApplication thisTaskApplication;
  bool userIsApplicant;
  bool isAdminView;
  GenchiUser applicant;
  GenchiUser hirer;
  bool emptyChat = false;

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
    thisTaskApplication = args.taskApplication;
    userIsApplicant = args.userIsApplicant;
    isAdminView = args.adminView;
    applicant = args.applicant;
    hirer = args.hirer;

    if (kDebugMode)
      print(
          'Application Chat Screen: this applicationid is ${thisTaskApplication.applicationId}');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: ChatNavigationBar(
          user: userIsApplicant ? applicant : hirer,
          otherUser: userIsApplicant ? hirer : applicant,
        ),
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: CircularProgress(),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder(
                  stream: firestoreAPI.fetchTaskApplicantChatStream(
                    taskId: thisTaskApplication.taskid,
                      applicationId: thisTaskApplication.applicationId),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgress();
                    }

                    var messagesSnapshot = snapshot.data;
                    List<QueryDocumentSnapshot> messages =
                        messagesSnapshot.docs;

                    List<Widget> messageBubbles = [];
                    for (QueryDocumentSnapshot message in messages) {
                      final messageText = message.data()['text'];
                      final messageSender = message.data()['sender'];
                      final messageTime = message.data()['time'];

                      final messageWidget = MessageBubble(
                        text: messageText,
                        sender: messageSender,
                        isMe: userIsApplicant
                            ? messageSender == applicant.id
                            : messageSender == hirer.id,
                        time: messageTime,
                      );
                      messageBubbles.add(messageWidget);
                    }

                    if (messageBubbles.isEmpty && userIsApplicant) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: MaterialButton(
                          enableFeedback: false,
                          onPressed: (){},
                          height: 50,
                          color: Color(kGenchiLightOrange),
                            child: Center(
                              child: Text(
                                  "Send ${hirer.name} a message letting them know why you've applied!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16,color: Colors.black, fontWeight: FontWeight.w400),),
                            )),
                      );
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
                if (!isAdminView)
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
                        TextButton(
                          onPressed: () async {
                            if (messageText != null) {


                              setState(() => messageTextController.clear());

                              analytics.logEvent(
                                  name: 'application_message_sent');

                              await firestoreAPI.addMessageToTaskApplicant(
                                taskId: thisTaskApplication.taskid,
                                  applicationId:
                                      thisTaskApplication.applicationId,
                                  chatMessage: ChatMessage(
                                      sender: userIsApplicant
                                          ? applicant.id
                                          : hirer.id,
                                      text: messageText,
                                      time: Timestamp.now()),
                                  applicantIsSender: userIsApplicant);
                              messageText = null;
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
