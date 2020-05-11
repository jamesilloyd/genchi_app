import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/chat_message_bubble.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/CRUDModel.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

//ToDo: create button that can go to their account (maybe on the Navigation bar)

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;


  //ToDo: need to work out how to use OnWillPop to implement chat deletion
  @override
  Widget build(BuildContext context) {

    final ChatScreenArguments args = ModalRoute.of(context).settings.arguments;
    final bool userIsProvider = args.userIsProvider;
    final Chat thisChat = args.chat;
    final ProviderUser provider = args.provider;
    final User user = args.user;
    final bool isFirstInstance = args.isFirstInstance;

    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: userIsProvider ? user.name : provider.name),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamBuilder(
              stream: firestoreAPI.fetchChatStream(thisChat.chatid),
              builder: (context,snapshot){
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color(kGenchiOrange),
                    ),
                  );
                }

                final messages = snapshot.data.documents;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages) {
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];

                  final messageWidget = MessageBubble(
                    text: messageText,
                    sender: messageSender,
                    isMe: userIsProvider ? messageSender == provider.pid : messageSender == user.id,
                  );
                  messageBubbles.add(messageWidget);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageBubbles,
                  ),
                );
              },
            ),


//            MessagesStream(),
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
                        //Do something with the user input.
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
                    onPressed: () {
                      messageTextController.clear();
                      firestoreAPI.addMessageToChat(chatId: thisChat.chatid,chatMessage: ChatMessage(sender: userIsProvider ? provider.pid : user.id, text: messageText, time: Timestamp.now()),providerIsSender: userIsProvider ? true : false );
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
    );
  }
}

