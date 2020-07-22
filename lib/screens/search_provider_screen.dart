import 'package:flutter/material.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/models/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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

  final Service service;

  SearchProviderScreen({Key key, @required this.service}) : super(key: key);

  @override
  _SearchProviderScreenState createState() => _SearchProviderScreenState();
}

class _SearchProviderScreenState extends State<SearchProviderScreen> {

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;

  Future getProvidersByService;

  @override
  void initState() {
    super.initState();
    getProvidersByService = firestoreAPI.getProvidersByService(serviceType: widget.service.databaseValue);
  }
  @override
  Widget build(BuildContext context) {

    final providerService = Provider.of<ProviderService>(context);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: CircularProgress(),
      child: Scaffold(
          appBar: BasicAppNavigationBar(barTitle: widget.service.namePlural),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: FutureBuilder(
                future: getProvidersByService,
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
                          'No Providers Yet',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  }

                  List<ProviderCard> providerCards = [];

                  for (ProviderUser provider in providers) {

                    ProviderCard pCard = ProviderCard(
                      provider: provider,
                      onTap: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        await providerService.updateCurrentProvider(provider.pid);

                        setState(() {
                          showSpinner = false;
                        });

                        Navigator.pushNamed(context, ProviderScreen.id);
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
          )),
    );
  }
}
