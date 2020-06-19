import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
import 'package:genchi_app/models/screen_arguments.dart';
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
class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin{

  List<User> users;
  List<ProviderUser> providers;

  TextEditingController searchTextController = TextEditingController();

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;
  Future searchTasksFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchTasksFuture = firestoreAPI.fetchTasksAndHirers();


  }

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
        child: DefaultTabController(
          initialIndex: 1,
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                title: Text(
                  'Search',
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
                      Tab(text: 'Tasks'),
                      Tab(text: 'Providers'),
                    ])),
            body: TabBarView(
              children: <Widget>[
                RefreshIndicator(
                  color: Color(kGenchiOrange),
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    searchTasksFuture = firestoreAPI.fetchTasksAndHirers();
                  },
                  child: SafeArea(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: FutureBuilder(
                      future: searchTasksFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgress(),
                          );
                        }

                        final List<Map<String, dynamic>> tasksAndHirers =
                            snapshot.data;

                        final List<Widget> widgets = [SizedBox(height: 10,)];

                        for (Map taskAndHirer in tasksAndHirers) {
                          Task task = taskAndHirer['task'];
                          User hirer = taskAndHirer['hirer'];

                          final widget = TaskCard(
                            image: hirer.displayPictureURL == null
                                ? AssetImage("images/Logo_Clear.png")
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
                              Navigator.pushNamed(context, TaskScreen.id)
                                  .then((value) {
                                setState(() {});
                              });
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
                ),
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
      ),
    );
  }
}
