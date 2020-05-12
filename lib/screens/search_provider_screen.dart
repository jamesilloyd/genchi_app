import 'package:flutter/material.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'provider_screen.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';

import 'package:provider/provider.dart';


class SearchProviderScreen extends StatefulWidget {

  static const String id = "search_provider_screen";

  @override
  _SearchProviderScreenState createState() => _SearchProviderScreenState();
}

class _SearchProviderScreenState extends State<SearchProviderScreen> {

  FirestoreCRUDModel firestoreAPI = FirestoreCRUDModel();

  //ToDo: add this to CRUDModel
  Future<List<ProviderUser>> getProvidersByService(serviceType) async {
    List<ProviderUser> providers = [];
    List<ProviderUser> allProviders = await firestoreAPI.fetchProviders();
    for(ProviderUser provider in allProviders){
      if(provider.type == serviceType) providers.add(provider);
    }

    return providers;
  }

  @override
  Widget build(BuildContext context) {

    final SearchProviderScreenArguments args = ModalRoute.of(context).settings.arguments;
    final providerService = Provider.of<ProviderService>(context);

    Map service = args.service;

    return Scaffold(
        appBar: MyAppNavigationBar(barTitle: service['plural']),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FutureBuilder(
              future: getProvidersByService(service['name']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgress();
                }

                final List<ProviderUser> providers = snapshot.data;

                List<ProviderCard> providerCards = [];

                for (ProviderUser provider in providers) {
                  ProviderCard pCard = ProviderCard(
                    //ToDo: implement dp
                    image: AssetImage("images/Logo_Clear.png"),
                    name: provider.name,
                    description: provider.bio,
                    onTap: () async {

                      await providerService.updateCurrentProvider(provider.pid);

                      Navigator.pushNamed(context, ProviderScreen.id,
                          arguments:
                          ProviderScreenArguments(provider: provider));
                    },
                  );

                  providerCards.add(pCard);
                }

                return ListView(
                  children: providerCards,
                );
              },
            )

//            ListView(
//              children: <Widget>[
//                ProviderCard(
//                  image: AssetImage("images/Logo_Clear.png"),
//                  name: 'Rotter',
//                  description: 'I am rotter',
//                  onTap: () {
//                    Navigator.pushNamed(context, ProviderScreen.id);
//                  },
//                ),
//                ProviderCard(
//                  image: AssetImage("images/Logo_Clear.png"),
//                  name: 'James',
//                  onTap: () {},
//                  description: "I am James",
//                ),
//                ProviderCard(
//                  image: AssetImage("images/Logo_Clear.png"),
//                  name: 'Hector',
//                  onTap: () {},
//                  description:
//                      "I am Hectoooooooooooooooooooooooooooooooooooooooooooooor",
//                ),
//              ],
//            ),
          ),
        ));
  }
}
