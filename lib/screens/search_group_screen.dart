import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/profile_cards.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/user_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class SearchGroupScreen extends StatefulWidget {

  final String accountType;

  SearchGroupScreen({Key key, @required this.accountType}) : super(key: key);

  @override
  _SearchGroupScreenState createState() => _SearchGroupScreenState();
}

class _SearchGroupScreenState extends State<SearchGroupScreen> {
  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    final accountService = Provider.of<AccountService>(context);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      progressIndicator: CircularProgress(),
      child: Scaffold(
          appBar: BasicAppNavigationBar(barTitle: widget.accountType == 'Charity' ? 'Charities':'Societies'),
          body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: FutureBuilder(
                future: firestoreAPI.getUsersByAccountType(accountType: widget.accountType),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: CircularProgress(),
                    );
                  }

                  final List<User> serviceProviders = snapshot.data;

                  if (serviceProviders.isEmpty) {
                    return Container(
                      height: 30,
                      child: Center(
                        child: Text(
                          'Nothing to display',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  }

                  List<UserCard> userCards = [];

                  for (User serviceProvider in serviceProviders) {

                    UserCard userCard = UserCard(
                      user: serviceProvider,
                      onTap: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        await accountService.updateCurrentAccount(id: serviceProvider.id);

                        setState(() {
                          showSpinner = false;
                        });

                        Navigator.pushNamed(context, UserScreen.id);
                      },
                    );

                    userCards.add(userCard);
                  }

                  return ListView(
                    children: userCards,
                  );
                },
              )
          )),
    );
  }
}
