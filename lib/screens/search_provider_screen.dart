import 'package:flutter/material.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'provider_screen.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/provider_service.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';



class SearchProviderScreen extends StatefulWidget {

  static const String id = "search_provider_screen";

  @override
  _SearchProviderScreenState createState() => _SearchProviderScreenState();
}

class _SearchProviderScreenState extends State<SearchProviderScreen> {

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  //ToDo: add this to CRUDModel
  Future<List<ProviderUser>> getProvidersByService(serviceType) async {
    List<ProviderUser> providers = [];
    //TODO change this so it finds provider by service type
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
                    image: provider.displayPictureURL == null ? AssetImage("images/Logo_Clear.png") : CachedNetworkImageProvider(provider.displayPictureURL),
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
          ),
        ));
  }
}
