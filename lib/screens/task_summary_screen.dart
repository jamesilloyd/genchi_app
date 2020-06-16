import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/task_card.dart';
import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_screen.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';

import 'package:provider/provider.dart';

class TaskSummaryScreen extends StatelessWidget {

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  Widget build(BuildContext context) {
    print('Task Screen Activated');
    final authProvider = Provider.of<AuthenticationService>(context);
    final taskProvider = Provider.of<TaskService>(context);
    User currentUser = authProvider.currentUser;
    bool userIsProvider = currentUser.providerProfiles.isNotEmpty;

    return DefaultTabController(
      length: userIsProvider ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Text(
              'Tasks',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(kGenchiGreen),
            elevation: 2.0,
            brightness: Brightness.light,
            bottom: TabBar(
                indicatorColor: Color(kGenchiOrange),
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontFamily: 'FuturaPT',
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Posted'),
                  if(userIsProvider) Tab(text: 'Applied'),
                ]
            )
        ),
        body: TabBarView(
          children: <Widget>[
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: <Widget>[
                  Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Your Posted Tasks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(kGenchiBlue),
                          fontWeight: FontWeight.w400,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 0,
                  ),
                  FutureBuilder(
                    future: firestoreAPI.getTasks(postIds: currentUser.posts),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgress();
                      }

                      final List<Task> userPosts = snapshot.data;

                      if(userPosts.isEmpty){
                        return  Container(
                          height: 30,
                          child: Center(
                            child: Text(
                              'You have not posted a task',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      }

                      List<Widget> taskWidgets = [];

                      for(Task post in userPosts) {
                        Widget tCard = TaskCard(
                            image: currentUser.displayPictureURL == null ? AssetImage("images/Logo_Clear.png") : CachedNetworkImageProvider(currentUser.displayPictureURL),
                            task: post,
                            onTap: () async {
                              await taskProvider.updateCurrentTask(taskId: post.taskId);
                              Navigator.pushNamed(context, TaskScreen.id);
                            }
                        );
                        taskWidgets.add(tCard);
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: taskWidgets,
                      );
                    },
                  ),
                ],
              ),
            ),
            if(userIsProvider) SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: <Widget>[
                  Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Your Applied Tasks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(kGenchiBlue),
                          fontWeight: FontWeight.w400,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 0,
                  ),

                  FutureBuilder(
                    future: firestoreAPI.getProviderTasksAndHirers(pids: currentUser.providerProfiles),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgress();
                      }

                      final List<Map<String, dynamic>> tasksAndHirers = snapshot.data;


                      if(tasksAndHirers.isEmpty){
                        return  Container(
                          height: 30,
                          child: Center(
                            child: Text(
                              'You have not applied to any tasks',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        );
                      }
                      List<Widget> taskWidgets = [];

                      for (Map taskAndHirer in tasksAndHirers) {

                        Task task = taskAndHirer['task'];
                        User hirer = taskAndHirer['hirer'];

                        Widget tCard = TaskCard(
                            image: hirer.displayPictureURL == null ? AssetImage("images/Logo_Clear.png") : CachedNetworkImageProvider(hirer.displayPictureURL),
                            task: task,
                            onTap: () async {
                              await taskProvider.updateCurrentTask(taskId: task.taskId);
                              Navigator.pushNamed(context, TaskScreen.id);
                            }
                        );
                        taskWidgets.add(tCard);
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: taskWidgets,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        )
      );
  }
}
