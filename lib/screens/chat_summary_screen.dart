import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';

import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/screens/application_chat_screen.dart';
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
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

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
    GenchiUser user =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;
    accountIdsAndNames.add({'id': user.id, 'name': user.name});

    chatSummaryStream = firestoreAPI.streamUserChatsAndApplications(user: user);
    getProvidersFuture =
        firestoreAPI.getServiceProviders(ids: user.providerProfiles);
  }

  //TOOD: ADD IN A PULL TO REFRESH HERE

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
          barTitle: 'Messages',
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            children: <Widget>[
              userIsProvider
                  ? FutureBuilder(
                      future: getProvidersFuture,
                      builder: (context, snapshot) {


                        if (!snapshot.hasData) {
                          return Column(
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
                          );
                        } else {
                          List serviceAccounts = snapshot.data;

                          ///Refresh the list (so it doesn't keep growing)
                          accountIdsAndNames.clear();
                          accountIdsAndNames.add({'id': 'ALL', 'name': 'ALL'});
                          accountIdsAndNames.add({
                            'id': currentUser.id,
                            'name': '${currentUser.name} (Main)'
                          });

                          for (GenchiUser account in serviceAccounts) {
                            accountIdsAndNames.add({
                              'id': account.id,
                              'name': '${account.name} - ${account.category}'
                            });
                          }

                          return Column(
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
                                            child: Text(
                                                '${currentUser.name} (Main)'),
                                            value: currentUser.id,
                                          ),
                                        ];
                                        for (GenchiUser account
                                            in serviceAccounts) {
                                          items.add(new PopupMenuItem<String>(
                                            child: Text(
                                                '${account.name} - ${account.category}'),
                                            value: account.id,
                                          ));
                                        }
                                        return items;
                                      },
                                      onSelected: (value) {
                                        for (Map map in accountIdsAndNames) {
                                          if (map['id'] == value) {
                                            filter = map['id'];
                                            filterText = map['name'];
                                          }
                                        }
                                        setState(() {});
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
                          );
                        }
                      },
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          thickness: 1,
                          height: 0,
                        ),
                      ],
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

                    List chatsAndUsers = snapshot.data[0];
                    List tasksApplicationsApplied = snapshot.data[1];
                    List taskApplicationsPosted = snapshot.data[2];

                    chatsANDApplications.addAll(chatsAndUsers);
                    chatsANDApplications.addAll(tasksApplicationsApplied);
                    chatsANDApplications.addAll(taskApplicationsPosted);

                    ///Sorting the entries by time
                    chatsANDApplications.sort((a, b) {
                      if (a != null && b != null) {
                        Timestamp timeA = a['data']['time'];
                        Timestamp timeB = b['data']['time'];

                        return timeB.compareTo(timeA);
                      } else
                        return null;
                    });

                    for (Map chatORApplication in chatsANDApplications) {
                      if (chatORApplication != null) {
                        if (chatORApplication['type'] == 'chat') {
                          ///We're dealing with a chat
                          Chat chat = chatORApplication['data']['chat'];
                          GenchiUser user = chatORApplication['data']['user'];
                          GenchiUser otherUser =
                              chatORApplication['data']['otherUser'];
                          bool userIsUser1 =
                              chatORApplication['data']['userIsUser1'];

                          if ((filter == user.id || filter == 'ALL')) {
                            ///Users main account messages
                            Widget chatWidget = MessageListItem(
                              imageURL: otherUser.displayPictureURL,
                              name: otherUser.name,
                              lastMessage: chat.lastMessage,
                              time: chat.time,
                              hasUnreadMessage: userIsUser1
                                  ? chat.user1HasUnreadMessage
                                  : chat.user2HasUnreadMessage,
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
                                    title:
                                        "Are you sure you want delete chat?");

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
                        } else if (chatORApplication['type'] == 'taskApplied') {
                          ///We're dealing with an task applied
                          TaskApplication application =
                              chatORApplication['data']['application'];
                          GenchiUser hirer = chatORApplication['data']['hirer'];
                          GenchiUser applicant =
                              chatORApplication['data']['applicant'];
                          Task task = chatORApplication['data']['task'];

                          ///Users task application message

                          Widget taskApplicationWidget = AppliedTaskChat(
                            imageURL: hirer.displayPictureURL,
                            title: task.title,
                            lastMessage: application.lastMessage,
                            time: application.time,
                            hasUnreadMessage:
                                application.applicantHasUnreadMessage,
                            onTap: () async {
                              setState(() {
                                showSpinner = true;
                              });

                              ///Check that the hirer exists before opening chat

                              application.applicantHasUnreadMessage = false;
                              await firestoreAPI.updateTaskApplication(
                                  taskApplication: application);

                              setState(() {
                                showSpinner = false;
                              });

                              ///Segue to application chat screen with user as the applicant
                              Navigator.pushNamed(
                                  context, ApplicationChatScreen.id,
                                  arguments: ApplicationChatScreenArguments(
                                    hirer: hirer,
                                    userIsApplicant: true,
                                    taskApplication: application,
                                    applicant: applicant,
                                  ));
                            },
                            deleteMessage: 'Withdraw',
                            hideChat: () {
                              //TODO implement this
                            },
                          );

                          chatWidgets.add(taskApplicationWidget);
                        } else if (chatORApplication['type'] == 'taskPosted') {
                          bool hirerHasUnreadNotification = false;

                          ///We're dealing with an task posted
                          Task task = chatORApplication['data']['task'];
                          List<Map<String, dynamic>> applicationsAndApplicants =
                              chatORApplication['data']['list'];

                          ///First create messageListItems for each chat
                          List<Widget> applicationChatWidgets = [];
                          for (Map<String, dynamic> applicationAndApplicant
                              in applicationsAndApplicants) {
                            TaskApplication taskApplication =
                                applicationAndApplicant['application'];
                            GenchiUser applicant =
                                applicationAndApplicant['applicant'];

                            if (taskApplication.hirerHasUnreadMessage)
                              hirerHasUnreadNotification = true;

                            MessageListItem chatWidget = MessageListItem(
                                imageURL: applicant.displayPictureURL,
                                name: applicant.name,
                                lastMessage: taskApplication.lastMessage,
                                time: taskApplication.time,
                                hasUnreadMessage:
                                    taskApplication.hirerHasUnreadMessage,
                                onTap: () async {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  GenchiUser hirer = currentUser;

                                  taskApplication.hirerHasUnreadMessage = false;

                                  ///Update the task application
                                  await firestoreAPI.updateTaskApplication(
                                      taskApplication: taskApplication);

                                  setState(() {
                                    showSpinner = false;
                                  });

                                  ///Segue to application chat screen with user as hirer
                                  Navigator.pushNamed(
                                      context, ApplicationChatScreen.id,
                                      arguments: ApplicationChatScreenArguments(
                                          adminView: false,
                                          taskApplication: taskApplication,
                                          userIsApplicant: false,
                                          applicant: applicant,
                                          hirer: hirer));
                                },

                                //TODO add ability to delete applicant
                                hideChat: () {});

                            applicationChatWidgets.add(chatWidget);
                          }

                          Widget taskPostedApplications = PostedTaskChats(
                            title: task.title,
                            hasUnreadMessage: hirerHasUnreadNotification,
                            messages: applicationChatWidgets,
                            hirer: currentUser,
                            time: chatORApplication['data']['time'],
                          );

                          chatWidgets.add(taskPostedApplications);
                        }
                      }
                    }

                    if (chatWidgets.isEmpty) {
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
