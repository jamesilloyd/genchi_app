import 'package:flutter/material.dart';
import 'package:genchi_app/components/profile_cards.dart';

import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/user_screen.dart';
import 'package:genchi_app/services/account_service.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';

import 'package:genchi_app/models/user.dart';

import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:genchi_app/services/authentication_service.dart';

import 'package:provider/provider.dart';

class FavouritesScreen extends StatelessWidget {
  static const id = 'favourites_screen';

  final FirestoreAPIService firestoreAPI = FirestoreAPIService();

  @override
  Widget build(BuildContext context) {
    final accountService = Provider.of<AccountService>(context);
    final authProvider = Provider.of<AuthenticationService>(context);

    GenchiUser currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BasicAppNavigationBar(
        barTitle: 'Favourites',
      ),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: <Widget>[
          FutureBuilder(
            ///This function returns a list of providerUsers
            future: firestoreAPI.getUsersFavourites(currentUser.favourites),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgress();
              }
              final List<GenchiUser> favouriteUsers = snapshot.data;

              if (favouriteUsers.isEmpty) {
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

              if(debugMode) print('Favourite Screen: Providers from firebase: $favouriteUsers');

              List<UserCard> userCards = [];

              for (GenchiUser favouriteUser in favouriteUsers) {
                UserCard userCard = UserCard(
                  user: favouriteUser,
                  onTap: () async {
                    await accountService.updateCurrentAccount(id: favouriteUser.id);
                    Navigator.pushNamed(context, UserScreen.id);
                  },
                );

                userCards.add(userCard);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: userCards,
              );
            },
          ),
        ],
      ),
    );
  }
}
