import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/search_service_tile.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/search_bar.dart';

import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/services.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/screens/search_manual_screen.dart';

import 'search_provider_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<User> users;
  List<ProviderUser> providers;

  TextEditingController searchTextController = TextEditingController();

  final FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Search screen activated');
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MyAppNavigationBar(barTitle: "Search"),
        body: Center(
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
                    Navigator.pushNamed(context, SearchProviderScreen.id,
                        arguments:
                            SearchProviderScreenArguments(service: service));
                  },
                  buttonTitle: service['plural'],
                  imageAddress: service['imageAddress'],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
