import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/components/app_bar.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/components/search_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/task_card.dart';

import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_screen.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/screens/search_manual_screen.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'search_provider_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

//TODO for some reason keeping the page alive is not working
//TODO can we implement pagination please!!!!
class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  List<User> users;
  List<ProviderUser> providers;

  TextEditingController searchTextController = TextEditingController();

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();
  Future searchTasksFuture;

  bool showSpinner = false;
  String filter = 'ALL';

  Map<String, Future> serviceFutures = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  void initState() {
    super.initState();
//    for (Job job in jobsList) {
////      serviceFutures[service['name']] =
////          firestoreAPI.fetchTasksAndHirersByService(service: service['name']);
//    }
    searchTasksFuture = firestoreAPI.fetchTasksAndHirers();

  }

  List<Widget> buildServiceTiles() {
    List<Widget> searchServiceTiles = [];

    for (Service service in servicesList) {
      Widget tile = Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: SearchServiceTile(

          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchProviderScreen(service: service)));
//            Navigator.pushNamed(context, SearchProviderScreen.id,
//                arguments: SearchProviderScreenArguments(service: service));
          },
          buttonTitle: service.namePlural,
          imageAddress: service.imageAddress,
          width: (MediaQuery.of(context).size.width - 40) / 2.5,
        ),
      );
      searchServiceTiles.add(tile);
    }
    return searchServiceTiles;
  }

//  Widget buildJobRows() {
//    List<Widget> columnChildren = [];
//
//    for (Map service in servicesListMap) {
//      List<Widget> widgets = [
//        Padding(
//          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
//          child: Text(
//            service['name'].toString().toUpperCase(),
//            style: TextStyle(fontSize: 16),
//          ),
//        ),
//        FutureBuilder(
//          future: serviceFutures[service['name']],
//          builder: (context, snapshot) {
//            if (!snapshot.hasData) {
//              return Container(
//                height: 130,
//                child: Center(
//                  child: CircularProgress(),
//                ),
//              );
//            } else {
//              final List<Map<String, dynamic>> tasksAndHirers = snapshot.data;
//
//              if (tasksAndHirers.isEmpty) {
//                return Container(
//                  height: 40,
//                  child: Center(
//                    child: Text(
//                      'No Jobs Yet',
//                      style: TextStyle(fontSize: 20),
//                    ),
//                  ),
//                );
//              }
//
//              final List<Widget> taskWidgets = [];
//
//              for (Map taskAndHirer in tasksAndHirers) {
//                Task task = taskAndHirer['task'];
//                User hirer = taskAndHirer['hirer'];
//
//                final widget = Padding(
//                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
//                  child: TaskTile(
//                    image: hirer.displayPictureURL == null
//                        ? null
//                        : CachedNetworkImageProvider(hirer.displayPictureURL),
//                    task: task,
//                    name: hirer.name,
//                    width: (MediaQuery.of(context).size.width - 50) / 3.25,
//                    onTap: () async {
//                      setState(() {
//                        showSpinner = true;
//                      });
//
//                      await Provider.of<TaskService>(context, listen: false)
//                          .updateCurrentTask(taskId: task.taskId);
//
//                      setState(() {
//                        showSpinner = false;
//                      });
//                      Navigator.pushNamed(context, TaskScreen.id);
//                    },
//                  ),
//                );
//
//                taskWidgets.add(widget);
//              }
//
//              return Container(
//                height:
//                    (MediaQuery.of(context).size.width - 50) * 1.3 / 3.25 + 20,
//                child: Center(
//                  child: ListView(
//                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
//                    scrollDirection: Axis.horizontal,
//                    children: taskWidgets,
//                  ),
//                ),
//              );
//            }
//          },
//        ),
//      ];
//
//      columnChildren.addAll(widgets);
//    }
//    return Column(
//      mainAxisAlignment: MainAxisAlignment.start,
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: columnChildren,
//    );
//  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final taskProvider = Provider.of<TaskService>(context);

    print('Search screen activated');
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: CircularProgress(),
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: BasicAppNavigationBar(
              barTitle: 'Search',
            ),
            body: SafeArea(
              child: RefreshIndicator(
                color: Color(kGenchiOrange),
                backgroundColor: Colors.white,
                onRefresh: () async {
//                  for (Service service in servicesList) {
//                    serviceFutures[service.databaseValue] = firestoreAPI
//                        .fetchTasksAndHirersByService(service: service.databaseValue);
//                  }
                  firestoreAPI.fetchTasksAndHirers();
                  setState(() {});
                },
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'PROVIDERS',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            //TODO add this in when we have more services on the app
//                            GestureDetector(
//                              onTap: () {},
//                              child: Text(
//                                'See all',
//                                textAlign: TextAlign.end,
//                                style: TextStyle(
//                                    fontWeight: FontWeight.w500,
//                                    fontSize: 16,
//                                    color: Color(kGenchiGreen)),
//                              ),
//                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 0,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: (MediaQuery.of(context).size.width - 40) /
                              (2.5 * 1.6) +
                          15,
                      child: Center(
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                          scrollDirection: Axis.horizontal,
                          children: buildServiceTiles(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'JOBS',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                                child: Align(
                              alignment: Alignment.bottomCenter,
                              child: PopupMenuButton(
                                  elevation: 1,
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(filter.toUpperCase()),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.filter_list,
                                          color: Color(kGenchiBlue),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        )
                                      ]),
                                  itemBuilder: (_) {
                                    List<PopupMenuItem<String>> items = [
                                      const PopupMenuItem<String>(
                                          child: const Text('ALL'),
                                          value: 'ALL'),
                                    ];
                                    for (Service service in servicesList) {
                                      items.add(
                                        new PopupMenuItem<String>(
                                            child: Text(service.databaseValue
                                                .toUpperCase()),
                                            value: service.databaseValue),
                                      );
                                    }
                                    return items;
                                  },
                                  onSelected: (value) {
                                    setState(() {
                                      filter = value;
                                    });
                                  }),
                            )),
                            //TODO: add this when we have more search options
//                            GestureDetector(
//                              onTap: () {
//                                Navigator.pushNamed(context, SearchTasksScreen.id);
//                              },
//                              child: Text(
//                                'See all',
//                                textAlign: TextAlign.end,
//                                style: TextStyle(
//                                    fontWeight: FontWeight.w500,
//                                    fontSize: 16,
//                                    color: Color(kGenchiGreen)),
//                              ),
//                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Divider(
                        height: 0,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    //TODO: add this in when we want the second page options
//                    buildJobRows(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: FutureBuilder(
                        future: searchTasksFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              height: 60,
                              child: Center(
                                child: CircularProgress(),
                              ),
                            );
                          }
                          final List<Map<String, dynamic>> tasksAndHirers = snapshot.data;

                          final List<Widget> widgets = [
                          ];

                          for (Map taskAndHirer in tasksAndHirers) {
                            Task task = taskAndHirer['task'];
                            User hirer = taskAndHirer['hirer'];

                            if ((task.service == filter) || (filter == 'ALL')) {
                              final widget = TaskCard(
                                image: hirer.displayPictureURL == null
                                    ? null
                                    : CachedNetworkImageProvider(
                                        hirer.displayPictureURL),
                                task: task,
                                onTap: () async {
                                  setState(() {
                                    showSpinner = true;
                                  });

                                  await taskProvider.updateCurrentTask(
                                      taskId: task.taskId);

                                  setState(() {
                                    showSpinner = false;
                                  });
                                  Navigator.pushNamed(context, TaskScreen.id);
                                },
                              );

                              widgets.add(widget);
                            }
                          }

                          if(widgets.isEmpty) {
                            return Container(
                              height: 40,
                              child: Center(
                                child: Text(
                                  'No jobs yet. Check again later',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: widgets,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
