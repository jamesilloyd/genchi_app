import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/search_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/task_card.dart';

import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_screen.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/screens/search_manual_screen.dart';
import 'package:genchi_app/services/task_service.dart';

import 'search_provider_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<User> users;
  List<ProviderUser> providers;

  TextEditingController searchTextController = TextEditingController();

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskService>(context);

    print('Search screen activated');
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              iconTheme: IconThemeData(
                color: Color(kGenchiBlue),
              ),
              title: Text(
                'Search',
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
                    Tab(text: 'Tasks'),
                    Tab(text: 'Providers'),
                  ])),
          body: TabBarView(
            children: <Widget>[
              SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: FutureBuilder(
                  future: firestoreAPI.fetchTasks(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgress(),
                      );
                    }

                    final List<Task> tasks = snapshot.data;

                    final List<Widget> widgets = [];

                    for (Task task in tasks) {
                      final widget = TaskCard(
                        task: task,
                        onTap: () async {
                          await taskProvider.updateCurrentTask(taskId: task.taskId);
                          Navigator.pushNamed(context, TaskScreen.id);
                        },
                      );

                      widgets.add(widget);
                    }

                    return ListView(
                      children: widgets,
                    );
                  },
                ),
              )),
              SafeArea(
                child: Center(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    padding: EdgeInsets.all(20.0),
                    childAspectRatio: 1.618,
                    children: List.generate(
                      servicesListMap.length,
                      (index) {
                        Map service = servicesListMap[index];
                        return SearchServiceTile(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, SearchProviderScreen.id,
                                arguments: SearchProviderScreenArguments(
                                    service: service));
                          },
                          buttonTitle: service['plural'],
                          imageAddress: service['imageAddress'],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
