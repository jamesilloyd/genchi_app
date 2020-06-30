import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'package:genchi_app/screens/edit_task_screen.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  static const id = 'task_screen';

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {

  bool showSpinner = false;
  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  Widget buildVariableSection(
      {@required bool isUsersTask,
      @required bool hasApplied,
      @required bool userIsProvider,
      @required String hirerid,
      @required List<dynamic> usersAppliedChatAndProviderId,
      @required Function applyFunction,
      @required Task task}) {
    if (isUsersTask) {
      ///User is looking at their own task
      return FutureBuilder(
        future: firestoreAPI.getTaskChatsAndProviders(
            chatIdsAndPids: task.applicantChatsAndPids),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress();
          }

          final List<Map<String, dynamic>> chatsAndProviders = snapshot.data;

          if (chatsAndProviders.isEmpty) {
            return Center(
              child: Text(
                'No Applicants Yet',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          List<Widget> widgets = [
            Center(
              child: Text(
                'Applicants',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(
              height: 5,
              thickness: 1,
            ),
          ];

          for (Map chatAndProvider in chatsAndProviders) {
            Chat chat = chatAndProvider['chat'];
            ProviderUser provider = chatAndProvider['provider'];

            MessageListItem chatWidget = MessageListItem(
                image: provider.displayPictureURL == null
                    ? AssetImage("images/Logo_Clear.png")
                    : CachedNetworkImageProvider(provider.displayPictureURL),
                name: provider.name,
                service: provider.type,
                lastMessage: chat.lastMessage,
                time: chat.time,
                hasUnreadMessage: chat.userHasUnreadMessage,
                onTap: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  chat.userHasUnreadMessage = false;
                  User hirer = await firestoreAPI.getUserById(hirerid);
                  await firestoreAPI.updateChat(chat: chat);
                  setState(() {
                    showSpinner = false;
                  });
                  Navigator.pushNamed(context, ChatScreen.id,
                          arguments: ChatScreenArguments(
                              chat: chat,
                              userIsProvider: false,
                              provider: provider,
                              user: hirer,
                              isFirstInstance: false))
                      .then((value) {
                    setState(() {});
                  });
                },

                //TODO add ability to delete applicant
                hideChat: () {});

            widgets.add(chatWidget);
          }

          return Column(
            children: widgets,
          );
        },
      );
    } else if (!userIsProvider) {
      ///User cannot apply as they do not have a provider account
      return FutureBuilder(
        future: firestoreAPI.getUserById(task.hirerId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress();
          }

          User hirer = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hirer',
                style: TextStyle(
                  color: Color(kGenchiBlue),
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              HirerCard(hirer: hirer),
              Divider(
                thickness: 1,
              ),
              Center(
                  child: Text(
                'Create a provider account to apply',
                style: TextStyle(
                    fontSize: 20,
                    color: Color(kGenchiBlue),
                    fontWeight: FontWeight.w500),
              )),
            ],
          );
        },
      );
    } else if (hasApplied) {
      ///User has already applied to the task, so their message will be displayed
      return FutureBuilder(
        future: firestoreAPI.getTaskChatsAndProviders(
            chatIdsAndPids: usersAppliedChatAndProviderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress();
          }

          final List<Map<String, dynamic>> chatsAndProviders = snapshot.data;

          if (chatsAndProviders.isEmpty) {
            return Center(
              child: Text(
                'No Applicants Yet',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          List<Widget> widgets = [
            Text(
              'Hirer',
              style: TextStyle(
                color: Color(kGenchiBlue),
                fontSize: 25.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: firestoreAPI.getUserById(task.hirerId),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return Text('');
                }
                User hirer = snapshot.data;
                return HirerCard(hirer: hirer);
              },
            ),
            Divider(
              thickness: 1,
            ),
            Center(
              child: Text(
                'Your Application',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            )
          ];

          for (Map chatAndProvider in chatsAndProviders) {
            Chat chat = chatAndProvider['chat'];
            ProviderUser provider = chatAndProvider['provider'];

            MessageListItem chatWidget = MessageListItem(
                image: provider.displayPictureURL == null
                    ? AssetImage("images/Logo_Clear.png")
                    : CachedNetworkImageProvider(provider.displayPictureURL),
                name: provider.name,
                service: provider.type,
                lastMessage: chat.lastMessage,
                time: chat.time,
                deleteMessage: 'Withdraw',
                hasUnreadMessage: chat.providerHasUnreadMessage,
                onTap: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  chat.providerHasUnreadMessage = false;
                  User hirer = await firestoreAPI.getUserById(hirerid);
                  await firestoreAPI.updateChat(chat: chat);
                  setState(() {
                    showSpinner = false;
                  });
                  Navigator.pushNamed(context, ChatScreen.id,
                          arguments: ChatScreenArguments(
                              chat: chat,
                              userIsProvider: true,
                              provider: provider,
                              user: hirer,
                              isFirstInstance: false))
                      .then((value) {
                    setState(() {});
                  });
                },

                hideChat: () async {

                  bool withdraw = await showYesNoAlert(context: context, title: 'Withdraw your application?');

                  if(withdraw) {
                    setState(() {
                      showSpinner = true;
                    });

                    await firestoreAPI.removeTaskApplicant(
                        providerId: provider.pid,
                        chatId: chat.chatid,
                        taskId: chat.taskid);

                    Provider.of<TaskService>(context, listen: false).updateCurrentTask(taskId: task.taskId);

                    setState(() {
                      showSpinner = false;
                    });

                  }

                });

            widgets.add(chatWidget);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          );
        },
      );
    } else if (!hasApplied) {
      ///User has not applied, so apply button is shown
      return FutureBuilder(
        future: firestoreAPI.getUserById(task.hirerId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress();
          }

          User hirer = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hirer',
                style: TextStyle(
                  color: Color(kGenchiBlue),
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              HirerCard(hirer: hirer),
              Divider(
                thickness: 1,
              ),
              Center(
                child: RoundedButton(
                  fontColor: Color(kGenchiCream),
                  buttonColor: Color(kGenchiBlue),
                  buttonTitle: 'Apply',
                  onPressed: applyFunction,
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Center(
        child: Text('Error'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (debugMode) print('Task Screen: activated');
    final authProvider = Provider.of<AuthenticationService>(context);
    final taskProvider = Provider.of<TaskService>(context);
    User currentUser = authProvider.currentUser;
    Task currentTask = taskProvider.currentTask;
    bool isUsersTask = currentTask.hirerId == currentUser.id;

    bool hasApplied = false;
    List usersAppliedChatAndProviderid = [];
    for (Map chatsAndPids in taskProvider.currentTask.applicantChatsAndPids) {
      //TODO this is VERY VERY VERY ugly
      if (currentUser.providerProfiles.contains(chatsAndPids['pid'])) {
        hasApplied = true;
        usersAppliedChatAndProviderid.add(chatsAndPids);
      }
    }
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Job',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(kGenchiGreen),
        elevation: 2.0,
        brightness: Brightness.light,
        actions: <Widget>[
          if (isUsersTask)
            IconButton(
              icon: Icon(
                Platform.isIOS ? CupertinoIcons.settings : Icons.settings,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () async {

                Navigator.pushNamed(context, EditTaskScreen.id);


              },
            )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgress(),
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    currentTask.title,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Color(kGenchiBlue)),
                  ),
                ),
                Text(
                  currentTask.service,
//                textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Divider(thickness: 1),
            Container(
              child: Text(
                "Details",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(kGenchiBlue),
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              currentTask.details ?? "",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                "Timings",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(kGenchiBlue),
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              currentTask.date ?? "",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                "Price",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(kGenchiBlue),
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              currentTask.price ?? "",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 1,
            ),
            buildVariableSection(
              task: currentTask,
              hasApplied: hasApplied,
              usersAppliedChatAndProviderId: usersAppliedChatAndProviderid,
              isUsersTask: isUsersTask,
              userIsProvider: userIsProvider,
              hirerid: currentTask.hirerId,
              applyFunction: () async {
                if (userIsProvider) {
                  String selectedProviderId = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Color(kGenchiCream),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: ListView(
                        children: <Widget>[
                          Center(
                              child: Text(
                            'Apply with which provider account?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                          FutureBuilder(
                            //This function returns a list of providerUsers
                            future: firestoreAPI.getProviders(
                                pids: currentUser.providerProfiles),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgress();
                              }
                              final List<ProviderUser> providers = snapshot.data;

                              List<ProviderCard> providerCards = [];

                              for (ProviderUser provider in providers) {
                                ProviderCard pCard = ProviderCard(
                                  image: provider.displayPictureURL == null
                                      ? AssetImage("images/Logo_Clear.png")
                                      : CachedNetworkImageProvider(
                                          provider.displayPictureURL),
                                  name: provider.name,
                                  description: provider.bio,
                                  service: provider.type,
                                  onTap: () {
                                    Navigator.pop(context, provider.pid);
                                  },
                                );

                                providerCards.add(pCard);
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: providerCards,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                  if (debugMode)
                    print('Task Screen: applied with pid $selectedProviderId');

                  if (selectedProviderId != null) {
                    setState(() {
                      showSpinner = true;
                    });
                    DocumentReference chatRef = await firestoreAPI.applyToTask(
                        taskId: currentTask.taskId,
                        providerId: selectedProviderId,
                        userId: currentUser.id);
                    await authProvider.updateCurrentUserData();
                    await taskProvider.updateCurrentTask(taskId: currentTask.taskId);
                    Chat newChat = await firestoreAPI.getChatById(chatRef.documentID);
                    ProviderUser providerProfile = await firestoreAPI.getProviderById(selectedProviderId);
                    //TODO: pass the hirer into the the screen as an argument ? how does this link with taskProviderService
                    User hirer = await firestoreAPI.getUserById(currentTask.hirerId);
                    setState(() {
                      showSpinner = false;
                    });
                    Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreenArguments(
                        chat: newChat,
                        userIsProvider: true,
                        provider: providerProfile,
                        user: hirer,
                        isFirstInstance: false)).then((value) {
                          setState(() {});
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
