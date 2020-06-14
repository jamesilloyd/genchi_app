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
              color: Color(kGenchiBlue),
            ),
            title: Text(
              'Tasks',
              style: TextStyle(
                color: Color(kGenchiBlue),
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Color(kGenchiCream),
            elevation: 2.0,
            brightness: Brightness.light,
            bottom: TabBar(
                indicatorColor: Color(kGenchiOrange),
                labelColor: Color(kGenchiBlue),
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

                      List<TaskCard> taskWidgets = [];

                      for(Task post in userPosts) {
                        TaskCard tCard = TaskCard(
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
                    future: firestoreAPI.getProviderTasks(pids: currentUser.providerProfiles),
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
                      List<TaskCard> taskWidgets = [];

                      for(Task post in userPosts) {

                        TaskCard tCard = TaskCard(
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
          ],
        ),
        )
      );
  }
}
