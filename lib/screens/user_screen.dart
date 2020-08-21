import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'package:genchi_app/screens/edit_account_screen.dart';
import 'package:genchi_app/screens/edit_provider_account_screen.dart';
import 'package:genchi_app/screens/home_screen.dart';
import 'package:genchi_app/services/account_service.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  static const id = 'user_screen';

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  FirebaseAnalytics analytics = FirebaseAnalytics();

  FirestoreAPIService firestoreAPI = FirestoreAPIService();

  bool isUsersOwnProfile;

  ///The profile being viewed
  User account;

  ///The app user
  User currentUser;

  Widget buildActionSection(
      {@required bool isUsersProfile, @required User account, @required User currentUser}) {

    bool isFavourite = currentUser.favourites.contains(account.id);

    if (account.accountType == 'Service Provider') {
      ///looking at service provider profile
      if (isUsersProfile) {

        ///Looking at their own service profile
        return RoundedButton(
            buttonColor: Color(kGenchiGreen),
            buttonTitle: 'Edit Profile',
            fontColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(
                  context, EditProviderAccountScreen.id);
            }
        );
      } else {

        ///looking at someone else's provider profile
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: RoundedButton(
                buttonColor: Color(kGenchiOrange),
                buttonTitle: 'Message',
                fontColor: Colors.white,
                onPressed: () async {
                  List userChats = currentUser.chats;
                  List accountChats = account.chats;
                  List allChats = [userChats, accountChats];

                  final commonChatIds = allChats.fold<Set>(
                      allChats.first.toSet(),
                          (a, b) => a.intersection(b.toSet()));

                  if (kDebugMode)
                    print(
                        'User Screen: Common Chats = $commonChatIds');

                  if (commonChatIds.isEmpty) {

                    ///This is a new chat
                    Navigator.pushNamed(context, ChatScreen.id,
                        arguments: ChatScreenArguments(
                            chat: Chat(),
                            user1: currentUser,
                            user2: account,
                            userIsUser1: true,
                            isFirstInstance: true));
                  } else {
                    ///This is an existing chat
                    Chat existingChat = await firestoreAPI
                        .getChatById(commonChatIds.first);

                    ///Check that the chat exists in database
                    if (existingChat != null) {
                      ///Work out if the current user is user 1

                      //TODO: what if it is one of their provider accounts that is messaging the user???
                      bool currentUserIsUser1 = existingChat.id1 == currentUser.id;
                      Navigator.pushNamed(context, ChatScreen.id,
                          arguments: ChatScreenArguments(
                              chat: existingChat,
                              user1: currentUserIsUser1 ? currentUser : account,
                              user2: currentUserIsUser1 ? account : currentUser,
                            userIsUser1: currentUserIsUser1,
                          ));
                    }
                  }
                },
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1,
              child: RoundedButton(
                buttonColor: isFavourite
                    ? Color(kGenchiGreen)
                    : Color(kGenchiBlue),
                fontColor: Colors.white,
                buttonTitle: isFavourite
                    ? 'Added to Favourites'
                    : 'Add to Favourites',
                onPressed: () async {
                  if (isFavourite) {
                    await analytics.logEvent(
                        name: 'unfavourited_user',
                        );
                    await firestoreAPI.removeUserFavourite(
                        uid: currentUser.id,
                        favouriteId: account.id);
                  } else {
                    await analytics.logEvent(
                        name: 'favourited_user',
                        );
                    await firestoreAPI.addUserFavourite(
                        uid: currentUser.id,
                        favouriteId: account.id);
                  }

                  await Provider.of<AuthenticationService>(context, listen: false).updateCurrentUserData();
                  setState(() {});
                },
              ),
            ),
          ],
        );
      }
    } else {
      ///Looking at non service provider profile
      if (isUsersProfile) {
        return Column(
          children: [
            RoundedButton(
              buttonColor: Color(kGenchiOrange),
              buttonTitle: 'Edit Profile',
              fontColor: Colors.white,
              onPressed: () async {
                await analytics
                    .logEvent(name: 'hirer_edit_hirer_screen');
                Navigator.pushNamed(context, EditAccountScreen.id);
              },
            ),
            SizedBox(
              height: 10,
            ),
          ],
        );
      } else {
        return SizedBox();
      }
    }
  }


  Widget buildAdminSection({@required BuildContext context}) {

    AuthenticationService authService =
    Provider.of<AuthenticationService>(context, listen: false);

    AccountService accountService = Provider.of<AccountService>(context, listen: false);

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
        Center(
          child: Text(
              'id: ${accountService.currentAccount.id}'
          ),
        ),

        if(accountService.currentAccount.accountType == 'Service Provider') RoundedButton(
          buttonTitle: "Delete account",
          buttonColor: Color(kGenchiBlue),
          elevation: false,
          onPressed: () async {
            ///Get most up to data provider
            User serviceProvider = accountService.currentAccount;
            bool delete = await showYesNoAlert(
                context: context, title: 'Delete this account?');

            if (delete) {
              await FirebaseAnalytics().logEvent(
                  name: 'provider_account_deleted');
              await firestoreAPI.deleteServiceProvider(serviceProvider: serviceProvider);
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
    AccountService accountService = Provider.of<AccountService>(context);
    account = accountService.currentAccount;

    AuthenticationService authService =
    Provider.of<AuthenticationService>(context);
    currentUser = authService.currentUser;

    isUsersOwnProfile = (account.id == currentUser.id) ||
        currentUser.providerProfiles.contains(account.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BasicAppNavigationBar(
        barTitle: account.accountType,
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            DisplayPicture(
              imageUrl: account.displayPictureURL,
              height: 0.2,
              border: true,
            ),
            SizedBox(height: 10),
            Container(
              child: SelectableText(
                account.name,
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
            buildActionSection(
                isUsersProfile: isUsersOwnProfile,
                account: account,
                currentUser: currentUser),
            Divider(
              thickness: 1,
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
            SelectableLinkify(
              text: account.bio,
              onOpen: _onOpenLink,
              options: LinkifyOptions(humanize: false, defaultToHttps: true),
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 10),
            if(currentUser.admin) buildAdminSection(context: context),
          ],
        ),
      ),
    );
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    if (link.runtimeType == EmailElement) {
      //TODO handle email elements
    } else {
      String url = link.url;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $link';
      }
    }
  }
}
