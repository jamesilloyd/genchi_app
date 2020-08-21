import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:genchi_app/components/search_bar.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:genchi_app/models/provider.dart';

class SearchManualScreen extends StatefulWidget {
  static const id = 'search_manual_screen';

  @override
  _SearchManualScreenState createState() => _SearchManualScreenState();
}

class _SearchManualScreenState extends State<SearchManualScreen> {
  Future<QuerySnapshot> searchResults;

  TextEditingController searchTextController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 40) * .8,
                    child: SearchBar(
                      onSubmitted: (searchValue){
                        Future<QuerySnapshot> userResult = Firestore.instance.collection('providers').where('name', isGreaterThanOrEqualTo: searchValue).getDocuments();
                        setState(() {
                          searchResults = userResult;
                        });
                      },
                      searchTextController: searchTextController,
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 40) * .2,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(kGenchiOrange),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 0,
              ),
              searchResults == null ? Text("No results") : FutureBuilder<QuerySnapshot>(
                future: searchResults,
                builder: (context,snapshot){


                  if(snapshot.hasData){


                    List<ProviderCard> providerCards = [];

                    List<DocumentSnapshot> results = snapshot.data.documents;
                    List<ProviderUser> providers = results.map((doc) => ProviderUser.fromMap(doc.data)).toList();
                    print(providers);

                    providers.forEach((ProviderUser provider) {
                      ProviderCard pCard = ProviderCard(
                        provider: provider,
                        onTap: () async {

//                        await providerService.updateCurrentProvider(provider.pid);
//
//                        Navigator.pushNamed(context, ProviderScreen.id,
//                            arguments:
//                            ProviderScreenArguments(provider: provider));
                        },
                      );

                      providerCards.add(pCard);
                      print(provider.name);
                    });

                    return Flexible(
                      child: ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: providerCards),
                    );
                  } else {
                    return Text(
                      "Loading results"
                    );
                  }
              }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
