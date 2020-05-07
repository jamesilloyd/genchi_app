import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'chat_screen.dart';
import 'package:genchi_app/components/message_list_item.dart';


//TODO: create function that streams chats associated with the userid
//TODO: for each chat fetch the other user's data and display

class ChatSummaryScreen extends StatefulWidget {
  @override
  _ChatSummaryScreenState createState() => _ChatSummaryScreenState();
}

class _ChatSummaryScreenState extends State<ChatSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Messages"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: <Widget>[
              MessageListItem(
                image: AssetImage("images/Logo_Clear.png"),
                name: "Leroy",
                lastMessage: "Hey dude",
                time: "19:27 PM",
                hasUnreadMessage: true,
                newMesssageCount: 5,
                onTap: () {
                  Navigator.pushNamed(context, ChatScreen.id);
                },
                service: "Photographer",
              ),
              MessageListItem(
                image: AssetImage("images/Logo_Clear.png"),
                name: "Rotter",
                lastMessage: "Hey how's it going, are you ok?",
                time: "19:27 PM",
                hasUnreadMessage: true,
                newMesssageCount: 2,
                onTap: () {},
                service: "Barber",
              ),
              MessageListItem(
                image: AssetImage("images/Logo_Clear.png"),
                name: "Mabel",
                lastMessage: "Hey dude",
                time: "19:27 PM",
                hasUnreadMessage: false,
                onTap: () {},
                service: "Bicycle Repair",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
