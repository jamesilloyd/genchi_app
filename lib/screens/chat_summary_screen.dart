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
import 'package:genchi_app/services/notification_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/models/screen_arguments.dart';

import 'package:provider/provider.dart';


//TODO: this doesn't need to be a stream, just have a pull down button at the top and refresh it if a notification comes through!!!
class ChatSummaryScreen extends StatefulWidget {
  @override
  _ChatSummaryScreenState createState() => _ChatSummaryScreenState();
}

class _ChatSummaryScreenState extends State<ChatSummaryScreen>
    with AutomaticKeepAliveClientMixin {
  static final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

  bool showSpinner = false;

  Stream chatSummaryStream;

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(screenName: "/home/chat_summary_screen");
    GenchiUser user =
        Provider.of<AuthenticationService>(context, listen: false).currentUser;

    chatSummaryStream = firestoreAPI.streamUserChatsAndApplications(user: user);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              Column(
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
                  ///This variable is used to update the notifcations
                  int notifications = 0;

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


                    int index = 0;
                    List chatsAndUsers;
                    List taskApplicationsPosted;
                    List tasksApplicationsApplied = [];

                    for(List data in snapshot.data){
                      if(index == 0){

                        chatsAndUsers = data;


                      } else if (index ==1){
                        taskApplicationsPosted = data;

                      } else {
                        tasksApplicationsApplied.addAll(data);

                      }
                      index += 1;
                    }
                    // List chatsAndUsers = snapshot.data[0];
                    // List taskApplicationsPosted = snapshot.data[1];
                    // List tasksApplicationsApplied = snapshot.data[];

                    chatsANDApplications.addAll(chatsAndUsers);
                    chatsANDApplications.addAll(taskApplicationsPosted);
                    chatsANDApplications.addAll(tasksApplicationsApplied);

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

                          ///Update number of notifications
                          if (userIsUser1) {
                            if (chat.user1HasUnreadMessage) notifications += 1;
                          } else {
                            if (chat.user2HasUnreadMessage) notifications += 1;
                          }

                          ///Users main account messages
                          Widget chatWidget = MessageListItem(
                            imageURL: otherUser.displayPicture200URL ?? otherUser.displayPictureURL,
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
                        } else if (chatORApplication['type'] == 'taskApplied') {
                          ///We're dealing with a task applied
                          TaskApplication application =
                              chatORApplication['data']['application'];
                          GenchiUser hirer = chatORApplication['data']['hirer'];
                          GenchiUser applicant =
                              chatORApplication['data']['applicant'];
                          Task task = chatORApplication['data']['task'];

                          ///Update number of notifications
                          if (application.applicantHasUnreadMessage)
                            notifications += 1;

                          ///Users task application message
                          Widget taskApplicationWidget = AppliedTaskChat(
                            imageURL: hirer.displayPicture200URL ?? hirer.displayPictureURL,
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

                            if (taskApplication.hirerHasUnreadMessage) {
                              hirerHasUnreadNotification = true;

                              ///Update number of notifications
                              notifications += 1;
                            }

                            MessageListItem chatWidget = MessageListItem(
                                imageURL: applicant.displayPicture200URL ?? applicant.displayPictureURL,
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

                    Provider.of<NotificationService>(context, listen: false)
                        .updateJobNotifications(notifications: notifications);

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
