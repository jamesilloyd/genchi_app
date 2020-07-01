import 'package:flutter/material.dart';

import 'package:genchi_app/constants.dart';

import 'provider_screen.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/models/screen_arguments.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/provider_service.dart';
import 'package:genchi_app/services/authentication_service.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavouritesScreen extends StatelessWidget {
  static const id = 'favourites_screen';

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  Widget build(BuildContext context) {
    final providerService = Provider.of<ProviderService>(context);
    final authProvider = Provider.of<AuthenticationService>(context);

    User currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppNavigationBar(
        barTitle: 'Favourites',
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          FutureBuilder(
            //This function returns a list of providerUsers
            future: firestoreAPI.getUsersFavourites(currentUser.favourites),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgress();
              }
              final List<ProviderUser> providers = snapshot.data;

              if (providers.isEmpty) {
                return Container(
                  height: 30,
                  child: Center(
                    child: Text(
                      'You Have No Favourites',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              }

              if(debugMode) print('Favourite Screen: Providers from firebase: $providers');

              List<ProviderCard> providerCards = [];

              for (ProviderUser provider in providers) {
                ProviderCard pCard = ProviderCard(
                  image: provider.displayPictureURL == null
                      ? AssetImage("images/Logo_Clear.png")
                      : CachedNetworkImageProvider(provider.displayPictureURL),
                  name: provider.name,
                  description: provider.bio,
                  service: provider.type,
                  onTap: () async {
                    await providerService.updateCurrentProvider(provider.pid);
                    Navigator.pushNamed(context, ProviderScreen.id,
                        arguments: ProviderScreenArguments(provider: provider));
                  },
                );

                providerCards.add(pCard);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: providerCards,
              );
            },
          ),
        ],
      ),
    );
  }
}
