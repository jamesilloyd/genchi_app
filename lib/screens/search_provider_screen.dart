import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_cards.dart'
;
import 'provider_screen.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/CRUDModel.dart';
import 'package:genchi_app/models/authentication.dart';

import 'package:provider/provider.dart';


//TODO: Create function that streams providers by service type

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

    for( ProviderUser provider in allProviders){
      if(provider.type == serviceType) providers.add(provider);
    }

    return providers;
  }

  @override
  Widget build(BuildContext context) {

    final SearchProviderScreenArguments args = ModalRoute.of(context).settings.arguments;
    final providerService = Provider.of<ProviderService>(context);

    String service = args.service ?? '';

    return Scaffold(
        appBar: MyAppNavigationBar(barTitle: service),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FutureBuilder(
              future: getProvidersByService(service),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  //ToDo: Add in progressmodalhud
                  return Text("Loading Provider Accounts");
                }

                final List<ProviderUser> providers = snapshot.data;

                List<ProviderCard> providerCards = [];

                for (ProviderUser provider in providers) {
                  ProviderCard pCard = ProviderCard(
                    //ToDo: implement dp
                    image: AssetImage("images/Logo_Clear.png"),
                    name: provider.name,
                    description: provider.bio,
                    service: provider.type,
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
//                    //TODO: Need to pass provider id to Provider screen
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
