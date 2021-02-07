import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/task_screen_applicant.dart';
import 'package:genchi_app/screens/task_screen_hirer.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/task_service.dart';
import 'package:provider/provider.dart';

class DynamicLinkService{



  Future<void> initDynamicLinks(BuildContext context) async {
    ///This receives links if the app was never closed
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        print('App re-opened');
        handleDyanmicLink(link: deepLink,context: context);

        // Navigator.pushNamed(context, deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    ///This receives links if the app has been opened by the link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      print('App opened');
      handleDyanmicLink(link: deepLink,context: context);
    }
  }

  Future handleDyanmicLink({Uri link, BuildContext context}) async {
    var isTask = link.pathSegments.contains('task');
    if (isTask) {
      var id = link.queryParameters['id'];
      if (id != null) {
        //Navigate to the view

        TaskService taskProvider =
        Provider.of<TaskService>(context, listen: false);
        GenchiUser currentUser =
            Provider.of<AuthenticationService>(context, listen: false)
                .currentUser;
        await taskProvider.updateCurrentTask(taskId: id);

        ///Check whether it is the users task or not
        bool isUsersTask =
            taskProvider.currentTask.hirerId == currentUser.id;

        if (isUsersTask) {
          Navigator.pushNamed(context, TaskScreenHirer.id);
        } else {
          ///If viewing someone else's task, add their id to the viewedIds if it hasn't been added yet
          if (!taskProvider.currentTask.viewedIds.contains(currentUser.id))
            await FirestoreAPIService()
                .addViewedIdToTask(viewedId: currentUser.id, taskId: id);
          Navigator.pushNamed(context, TaskScreenApplicant.id);

        }
      }
    }

  }

  Future<String> createDynamicLink({String title, String taskId}) async {
    print('started generating link');

    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://genchi.page.link',
        link: Uri.parse('https://www.genchi.app/task?id=$taskId'),
        androidParameters: AndroidParameters(
          packageName: 'app.genchi.genchi',
          minimumVersion: 1,
        ),
        iosParameters: IosParameters(
          bundleId: 'com.james-lloyd.Genchi',
          minimumVersion: '1.0.18',
          appStoreId: '1473696183',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: title,
        ));

    var dynamicUrl = await parameters.buildUrl();

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    print('finished generating link');

    return shortUrl.toString();

    // return dynamicUrl;
  }
}