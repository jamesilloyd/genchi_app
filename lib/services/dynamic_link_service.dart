import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';

class DynamicLinkService {


  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;

      if (deepLink != null) {
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => TestScreen()));
        //  TODO: log it has been found
      }

      FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => TestScreen()));
        //  TODO: log it has been found
      });

    } catch (e) {
      print(e.toString());
    }
  }

  Future<Uri> createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://genchi.page.link',
      link: Uri.parse('https://genchi.page.link.com'),
      androidParameters: AndroidParameters(
        packageName: 'app.genchi.genchi',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.james-lloyd.Genchi',
        minimumVersion: '1',
        appStoreId: '1473696183',
      ),
    );
    var dynamicUrl = await parameters.buildUrl();

    return dynamicUrl;
  }




}