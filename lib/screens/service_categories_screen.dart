import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/screens/search_provider_screen.dart';

//TODO probably don't need this for now.
class ServiceCategoriesScreen extends StatefulWidget {
  static const id = 'service_categories_screen';
  @override
  _ServiceCategoriesScreenState createState() => _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    print('Search screen activated');
    return Scaffold(
      appBar: BasicAppNavigationBar(barTitle: "Service Providers"),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          padding: EdgeInsets.all(20.0),
          childAspectRatio: 1.618,
          children: List.generate(
            servicesList.length,
                (index) {
              Service service = servicesList[index];
              return SearchServiceTile(
                onPressed: () {
                  //TODO need to take spaces out of value
                  FirebaseAnalytics().logEvent(
                      name: 'search_button_clicked_for_${service.databaseValue}');

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchProviderScreen(service: service)));
                },
                buttonTitle: service.namePlural,
                imageAddress: service.imageAddress,
                width: (MediaQuery.of(context).size.width - 40) / 2,
              );
            },
          ),
        ),
      ),
    );
  }
}
