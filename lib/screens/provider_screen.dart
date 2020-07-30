import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/components/platform_alerts.dart';

import 'package:genchi_app/constants.dart';

import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/services/linkify_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_provider_account_screen.dart';
import 'chat_screen.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/user.dart';

import 'package:genchi_app/services/provider_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderScreen extends StatefulWidget {
  static const String id = "provider_screen";

  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  FirestoreAPIService firestoreAPI = FirestoreAPIService();
  bool isFavourite = false;

  Widget buildAdminSection({BuildContext context}) {
    return Column(
      children: <Widget>[
        Divider(
          thickness: 1,
        ),
        Center(
          child: Text(
            'Admin Controls',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          ),
        ),
        RoundedButton(
          buttonTitle: "Delete provider account",
          buttonColor: Color(kGenchiBlue),
          elevation: false,
          onPressed: () async {
            ProviderService providerService =
                Provider.of<ProviderService>(context, listen: false);
            AuthenticationService authService =
                Provider.of<AuthenticationService>(context, listen: false);

            ///Get most up to data provider
            ProviderUser providerUser = providerService.currentProvider;

            bool delete = await showYesNoAlert(
                context: context, title: 'Delete this provider account?');

            if (delete) {
              await firestoreAPI.deleteProvider(provider: providerUser);
              await authService.updateCurrentUserData();

              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.id, (Route<dynamic> route) => false,
                  arguments: HomeScreenArguments(startingIndex: 0));
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationService>(context);
    final providerService = Provider.of<ProviderService>(context);

    ProviderUser providerUser = providerService.currentProvider;
    bool isUsersProviderProfile =
        authProvider.currentUser.providerProfiles.contains(providerUser.pid);
    isFavourite =
        authProvider.currentUser.favourites.contains(providerUser.pid);

    if (debugMode) print('Provider screen: is favourite: $isFavourite');
    if (debugMode)
      print('Provider screen: is users p. profile: $isUsersProviderProfile');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BasicAppNavigationBar(
        barTitle: 'Provider',
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            DisplayPicture(
              imageUrl: providerUser.displayPictureURL,
              height: 0.2,
              border: true,
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                providerUser.name ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: RoundedButton(
                    buttonColor: isUsersProviderProfile
                        ? Color(kGenchiGreen)
                        : Color(kGenchiOrange),
                    buttonTitle: isUsersProviderProfile
                        ? 'Edit Provider Profile'
                        : 'Message',
                    fontColor: isUsersProviderProfile
                        ? Colors.white
                        : Color(kGenchiBlue),
                    onPressed: isUsersProviderProfile
                        ? () {
                            Navigator.pushNamed(
                                context, EditProviderAccountScreen.id);
                          }
                        : () async {
                            List userChats = authProvider.currentUser.chats;
                            if (kDebugMode)
                              print('Provider Screen: User Chats = $userChats');
                            List providerChats = providerUser.chats;
                            if (kDebugMode)
                              print(
                                  'Provider Screen: Provider Chats = $providerChats');
                            List allChats = [userChats, providerChats];

                            final commonChatIds = allChats.fold<Set>(
                                allChats.first.toSet(),
                                (a, b) => a.intersection(b.toSet()));

                            if (kDebugMode)
                              print(
                                  'Provider Screen: Common Chats = $commonChatIds');

                            if (commonChatIds.isEmpty) {
                              print("Empty");
                              Navigator.pushNamed(context, ChatScreen.id,
                                  arguments: ChatScreenArguments(
                                      chat: Chat(),
                                      provider: providerUser,
                                      user: authProvider.currentUser,
                                      isFirstInstance: true));
                            } else {
                              ///This is an existing chat
                              Chat existingChat = await firestoreAPI
                                  .getChatById(commonChatIds.first);

                              ///Check that the chat exists in database
                              if (existingChat != null) {
                                Navigator.pushNamed(context, ChatScreen.id,
                                    arguments: ChatScreenArguments(
                                        chat: existingChat,
                                        provider: providerUser,
                                        user: authProvider.currentUser));
                              }
                            }
                          },
                  ),
                ),
                if (!isUsersProviderProfile)
                  SizedBox(
                    width: 10,
                  ),
                if (!isUsersProviderProfile)
                  Expanded(
                    flex: 1,
                    child: RoundedButton(
                      buttonColor: isFavourite
                          ? Color(kGenchiGreen)
                          : Color(kGenchiBlue),
                      fontColor: Color(kGenchiCream),
                      buttonTitle: isFavourite
                          ? 'Added to Favourites'
                          : 'Add to Favourites',
                      onPressed: () async {
                        isFavourite
                            ? firestoreAPI.removeUserFavourite(
                                uid: authProvider.currentUser.id,
                                favouritePid: providerUser.pid)
                            : firestoreAPI.addUserFavourite(
                                uid: authProvider.currentUser.id,
                                favouritePid: providerUser.pid);
                        await authProvider.updateCurrentUserData();
                        setState(() {});
                      },
                    ),
                  ),
              ],
            ),
            Divider(
              thickness: 1,
            ),
            Container(
              child: Text(
                "Service",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SelectableText(
              providerUser.type ?? "",
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                "About Me",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Linkify(
              text: providerUser.bio ?? "",
              onOpen: _onOpenLink,
              options: LinkifyOptions(humanize: false, defaultToHttps: true),
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Text(
                "Experience",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Linkify(
              text: providerUser.experience ?? "",
              onOpen: _onOpenLink,
              style: TextStyle(
                fontSize: 16.0,
              ),
              options: LinkifyOptions(humanize: false),
            ),
            SizedBox(
              height: 10,
            ),
            if (authProvider.currentUser.admin)
              buildAdminSection(context: context),
          ],
        ),
      ),
    );
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    if (link.runtimeType == EmailElement) {
      //TODO handle email elements
    } else {
      String url = link.url.toLowerCase();
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $link';
      }
    }
  }
}
