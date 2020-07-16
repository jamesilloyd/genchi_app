import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/task_card.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_screen.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class SearchTasksScreen extends StatefulWidget {
  static const id = 'search_tasks_screen';

  @override
  _SearchTasksScreenState createState() => _SearchTasksScreenState();
}

class _SearchTasksScreenState extends State<SearchTasksScreen> {
  bool showSpinner = false;

  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  Future searchTasksFuture;


  @override
  void initState() {

    super.initState();
    searchTasksFuture = firestoreAPI.fetchTasksAndHirers();
  }

//  _AnimatedMovies = AllMovies.where((i) => i.isAnimated).toList();


  @override
  Widget build(BuildContext context) {

    final taskProvider = Provider.of<TaskService>(context);

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
            barTitle: 'Search Jobs',
          ),
          body: SafeArea(
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
              ),),

          ),
        ),
    );
  }
}
