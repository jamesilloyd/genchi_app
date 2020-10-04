import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';

import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/models/task.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/models/screen_arguments.dart';

import 'package:provider/provider.dart';

class ChatSummaryScreen extends StatefulWidget {
  @override
  _ChatSummaryScreenState createState() => _ChatSummaryScreenState();
}

class _ChatSummaryScreenState extends State<ChatSummaryScreen> {
  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  FirebaseAnalytics analytics = FirebaseAnalytics();

  bool showSpinner = false;

  Stream chatSummaryStream;
  Future getProvidersFuture;

  String filter = 'ALL';
  String filterText = 'ALL';

  List<Map> accountIdsAndNames = [
    {'id': 'ALL', 'name': 'ALL'}
  ];


  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/home/chat_summary_screen");
    GenchiUser user = Provider.of<AuthenticationService>(context,listen:false).currentUser;
    accountIdsAndNames.add({'id':user.id,'name':user.name});

    chatSummaryStream = firestoreAPI.streamUserChatsAndApplications(user: user);
    getProvidersFuture = firestoreAPI.getServiceProviders(
        ids: user.providerProfiles);

  }

  @override
  Widget build(BuildContext context) {
    print('Chat summary screen activated');

    final authProvider = Provider.of<AuthenticationService>(context);
    GenchiUser currentUser = authProvider.currentUser;
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
                FutureBuilder(
                  future: getProvidersFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      );
                    } else {
                      List serviceAccounts = snapshot.data;

                      ///Refresh the list (so it doesn't keep growing)
                      accountIdsAndNames.clear();
                      accountIdsAndNames.add({'id': 'ALL', 'name': 'ALL'});
                      accountIdsAndNames.add({'id':currentUser.id,'name':'${currentUser.name} (Main)'});

                      for (GenchiUser account in serviceAccounts) {
                        accountIdsAndNames
                            .add({'id': account.id, 'name': '${account.name} - ${account.category}'});
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
                                  child: PopupMenuButton(
                                    elevation: 1,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            filterText,
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
                                    itemBuilder: (_) {
                                      List<PopupMenuItem<String>> items = [
                                        new PopupMenuItem<String>(
                                          child: Text('ALL'),
                                          value: 'ALL',
                                        ),
                                        new PopupMenuItem<String>(
                                          child: Text('${currentUser.name} (Main)'),
                                          value: currentUser.id,
                                        ),
                                      ];
                                      for (GenchiUser account in serviceAccounts) {
                                        items.add(new PopupMenuItem<String>(
                                          child: Text('${account.name} - ${account.category}'),
                                          value: account.id,
                                        ));
                                      }
                                      return items;
                                    },
                                    onSelected: (value) {
                                      for(Map map in accountIdsAndNames){
                                        if(map['id'] == value) {
                                          filter = map['id'];
                                          filterText = map['name'];
                                        }
                                      }
                                      setState(() {
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              StreamBuilder(
                stream: chatSummaryStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      height: 60,
                      child: Center(
                        child: CircularProgress(),
                      ),
                    );
                  } else {


                    List<Widget> chatWidgets = [];
                    List chatsANDApplications = [];

                    /*TODO: collect streams for:
                       1. user chats
                       2. service provider chats
                       3. user task applications
                       4. service provider applications
                    */

                    // if (userIsProvider) {
                    //   ///Receiving chats for hiring and providing
                    //   List list1 = snapshot.data[0];
                    //   List list2 = snapshot.data[1];
                    //   chatsAndUsers.addAll(list1);
                    //   chatsAndUsers.addAll(list2);
                    //
                    //   chatsAndUsers.sort((a, b) {
                    //     if (a != null && b != null) {
                    //       Chat chatA = a['chat'];
                    //       Chat chatB = b['chat'];
                    //       return chatB.time.compareTo(chatA.time);
                    //     } else
                    //       return b.toString().compareTo(a.toString());
                    //   });
                    // } else {
                    //   ///Only receiving chats for hiring
                    //   chatsAndUsers = snapshot.data;
                    // }

                      List chatsAndUsers = snapshot.data[0];
                      List tasksApplicationsApplied = snapshot.data[1];
                      List taskApplicationsPosted = snapshot.data[2];

                      chatsANDApplications.addAll(chatsAndUsers);
                      chatsANDApplications.addAll(tasksApplicationsApplied);
                      chatsANDApplications.addAll(taskApplicationsPosted);

                      ///Sorting the entries by time
                      chatsANDApplications.sort((a,b) {
                        if(a != null && b != null){
                          Timestamp timeA = a['time'];
                          Timestamp timeB = b['time'];
                          return timeB.compareTo(timeA);
                        } else return null;
                      });

                    for (Map chatORApplication in chatsANDApplications) {
                      if (chatORApplication != null) {
                        if(chatORApplication['chat'] !=null){
                          ///We're dealing with a chat
                          Chat chat = chatORApplication['chat'];
                          GenchiUser user = chatORApplication['user'];
                          GenchiUser otherUser = chatORApplication['otherUser'];
                          bool userIsUser1 = chatORApplication['userIsUser1'];

                          if ((filter == user.id || filter == 'ALL')) {
                            ///Users main account messages
                            Widget chatWidget = MessageListItem(
                              imageURL: otherUser.displayPictureURL,
                              name: otherUser.name,
                              service: otherUser.category,
                              lastMessage: chat.lastMessage,
                              time: chat.time,
                              hasUnreadMessage: userIsUser1
                                  ? chat.user1HasUnreadMessage
                                  : chat.user2HasUnreadMessage,
                              type: otherUser.accountType == 'Service Provider' ? 'Individual' : otherUser.accountType,
                              deleteMessage: 'Archive',
                              onTap: () async {
                                setState(() {
                                  showSpinner = true;
                                });
                                userIsUser1
                                    ? chat.user1HasUnreadMessage = false
                                    : chat.user2HasUnreadMessage = false;
                                await firestoreAPI.updateChat(chat: chat);

                                setState(() {
                                  showSpinner = false;
                                });
                                Navigator.pushNamed(context, ChatScreen.id,
                                    arguments: ChatScreenArguments(
                                      chat: chat,
                                      user1: userIsUser1 ? user : otherUser,
                                      userIsUser1: userIsUser1,
                                      user2: userIsUser1 ? otherUser : user,
                                    ));
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
                                      chat: chat, hiddenId: user.id);

                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              },
                            );

                            if (userIsUser1) {
                              if (!chat.isHiddenFromUser1) {
                                chatWidgets.add(chatWidget);
                              }
                            } else {
                              if (!chat.isHiddenFromUser2) {
                                chatWidgets.add(chatWidget);
                              }
                            }
                          }
                        } else {

                          ///We're dealing with an application
                          //TODO: we're going to need the task document as well
                          TaskApplication application = chatORApplication['application'];
                          GenchiUser hirer = chatORApplication['hirer'];
                          GenchiUser applicant = chatORApplication['applicant'];
                          bool userIsHirer = chatORApplication['userIsHirer'];
                          Task task = chatORApplication['task'];

                          ///Users task application message

                          Widget taskApplicationWidget = MessageListItem(
                            imageURL: userIsHirer ? applicant.displayPictureURL:hirer.displayPictureURL,
                            // name: userIsHirer ? applicant.name : hirer.name,
                            name: task.title,
                            service: userIsHirer ? applicant.category : hirer.category,
                            lastMessage: application.lastMessage,
                            time: application.time,
                            type: userIsHirer ? applicant.accountType : hirer.accountType,
                            hasUnreadMessage: userIsHirer ? application.hirerHasUnreadMessage : application.applicantHasUnreadMessage,
                            onTap: (){},
                            deleteMessage: 'Withdraw',
                            hideChat: (){},

                          );

                          chatWidgets.add(taskApplicationWidget);
                        }


                      }
                    }

                    if (chatsAndUsers.isEmpty | chatWidgets.isEmpty) {
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

                    //TODO: sort all the widgets by time

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
