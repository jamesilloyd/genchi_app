import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'provider_screen.dart';

import 'package:genchi_app/models/screen_arguments.dart';


//TODO: Create function that streams providers by service type

class SearchProviderScreen extends StatefulWidget {
//  final String service;
  static const String id = "search_provider_screen";

//  const SearchProviderScreen({@required this.service});

  @override
  _SearchProviderScreenState createState() => _SearchProviderScreenState();
}

class _SearchProviderScreenState extends State<SearchProviderScreen> {
  @override
  Widget build(BuildContext context) {

    final SearchProviderScreenArguments args = ModalRoute.of(context).settings.arguments;
    String service = args.service ?? '';

    return Scaffold(
//      appBar: MyAppNavigationBar(barTitle: widget.service),
        appBar: MyAppNavigationBar(barTitle: service),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: <Widget>[
                ProviderCard(
                  image: AssetImage("images/Logo_Clear.png"),
                  name: 'Rotter',
                  description: 'I am rotter',
                  onTap: () {
                    //TODO: Need to pass provider id to Provider screen
                    Navigator.pushNamed(context, ProviderScreen.id);
                  },
                ),
                ProviderCard(
                  image: AssetImage("images/Logo_Clear.png"),
                  name: 'James',
                  onTap: () {},
                  description: "I am James",
                ),
                ProviderCard(
                  image: AssetImage("images/Logo_Clear.png"),
                  name: 'Hector',
                  onTap: () {},
                  description:
                      "I am Hectoooooooooooooooooooooooooooooooooooooooooooooor",
                ),
              ],
            ),
          ),
        ));
  }
}
