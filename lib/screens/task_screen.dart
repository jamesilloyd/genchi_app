import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/message_list_item.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatelessWidget {
  static const id = 'task_screen';

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  Widget buildVariableSection(
      {bool isUsersTask,
      bool hasApplied,
      bool userIsProvider,
      Function applyFunction,
      @required Task task}) {
    if (isUsersTask) {
      //TODO show applicants
      return FutureBuilder(
        future: firestoreAPI.getChatsAndProviders(chatIds: task.applicantChatIds),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress();
          }

          final Map<Chat, ProviderUser> chatsAndProviders = snapshot.data;

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
              color: Colors.black,
              thickness: 1,
            ),
          ];

          chatsAndProviders.forEach((key, value) {
            Chat chat = key;
            ProviderUser provider = value;

            MessageListItem chatWidget = MessageListItem(
              image: provider.displayPictureURL == null ? AssetImage("images/Logo_Clear.png") : CachedNetworkImageProvider(provider.displayPictureURL),
              name: provider.name,
              service: provider.type,
              lastMessage: chat.lastMessage,
              time: chat.time,
              hasUnreadMessage: chat.userHasUnreadMessage,
              onTap: (){},
//                  () async {
//                print('Navigating');
//                chat.userHasUnreadMessage = false;
//                await firestoreAPI.updateChat(chat: chat);
//                Navigator.pushNamed(context, ChatScreen.id,arguments: ChatScreenArguments(chat: chat, userIsProvider: false,provider: provider,user: currentUser, isFirstInstance: false));
//              },
            //TODO: add ability to delete applicant
              hideChat: (){}
            );

            widgets.add(chatWidget);
          });

//          for (ProviderUser provider in providers) {
//            ProviderCard pCard = ProviderCard(
//              image: provider.displayPictureURL == null
//                  ? AssetImage("images/Logo_Clear.png")
//                  : CachedNetworkImageProvider(provider.displayPictureURL),
//              name: provider.name,
//              description: provider.bio,
//              onTap: () {},
//            );
//
//            widgets.add(pCard);
//          }

          return Column(
            children: widgets,
          );
        },
      );
    } else if (!userIsProvider) {
      //TODO display this a little nicer
      return Center(child: Text('Create a provider account to apply'));
    } else if (hasApplied) {
      //TODO add the single message between you and the hirer
      return Center(child: Text('You have applied for this task'));
    } else if (!hasApplied) {
      return RoundedButton(
        fontColor: Color(kGenchiCream),
        buttonColor: Color(kGenchiBlue),
        buttonTitle: 'Apply',
        onPressed: applyFunction,
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
    bool isUsersTask = currentUser.posts.contains(currentTask.taskId);
    bool hasApplied = currentUser.providerAppliedTasks.contains(currentTask.taskId);
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return Scaffold(
      appBar: MyAppNavigationBar(
        barTitle: currentTask.title,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Text(currentTask.title),
          Text(currentTask.date),
          Text(currentTask.service),
          Text(currentTask.details),
          buildVariableSection(
            task: currentTask,
            hasApplied: hasApplied,
            isUsersTask: isUsersTask,
            userIsProvider: userIsProvider,
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
                  await firestoreAPI.applyToTask(
                      taskId: currentTask.taskId,
                      providerId: selectedProviderId,
                      userId: currentUser.id);
                  await authProvider.updateCurrentUserData();
                  await taskProvider.updateCurrentTask(
                      taskId: currentTask.taskId);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
