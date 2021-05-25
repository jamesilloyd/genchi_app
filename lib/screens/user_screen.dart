import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/chat.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/chat_screen.dart';
import 'package:genchi_app/screens/edit_account_screen.dart';
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

  bool expandedDisplayPhoto = false;

  ///The profile being viewed
  GenchiUser account;

  ///The app user
  GenchiUser currentUser;

  Widget buildActionSection(
      {@required bool isUsersProfile,
      @required GenchiUser account,
      @required GenchiUser currentUser}) {
    bool isFavourite = currentUser.favourites.contains(account.id);

    if (isUsersProfile) {
      ///Looking at their own account
      return Center(
        child: RoundedButton(
            elevation: false,
            buttonColor: Color(kGenchiGreen),
            buttonTitle: 'Edit Profile',
            fontColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(
                  context,
                      EditAccountScreen.id);
            }),
      );
    } else {
      ///looking at someone else's account
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: RoundedButton(
              elevation: false,
              buttonColor: Color(kGenchiLightOrange),
              buttonTitle: 'Message',
              fontColor: Colors.black,
              onPressed: () async {
                List userChats = currentUser.chats;
                List accountChats = account.chats;
                List allChats = [userChats, accountChats];

                final commonChatIds = allChats.fold<Set>(allChats.first.toSet(),
                    (a, b) => a.intersection(b.toSet()));

                if (kDebugMode)
                  print('User Screen: Common Chats = $commonChatIds');

                if (commonChatIds.isEmpty) {
                  ///This is a new chat
                  await analytics.logEvent(name: 'new_private_chat_created');
                  Navigator.pushNamed(context, ChatScreen.id,
                      arguments: ChatScreenArguments(
                          chat: Chat(),
                          user1: currentUser,
                          user2: account,
                          userIsUser1: true,
                          isFirstInstance: true));
                } else {
                  ///This is an existing chat
                  Chat existingChat =
                      await firestoreAPI.getChatById(commonChatIds.first);

                  ///Check that the chat exists in database
                  if (existingChat != null) {
                    ///Work out if the current user is user 1

                    bool currentUserIsUser1 =
                        existingChat.id1 == currentUser.id;

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
              elevation: false,
              buttonColor:
                  isFavourite ? Color(kGenchiGreen) : Color(kGenchiLightBlue),
              fontColor: Colors.white,
              buttonTitle:
                  isFavourite ? 'Added to Favourites' : 'Add to Favourites',
              onPressed: () async {
                if (isFavourite) {
                  await analytics.logEvent(
                    name: 'unfavourited_user',
                  );
                  await firestoreAPI.removeUserFavourite(
                      uid: currentUser.id, favouriteId: account.id);
                } else {
                  await analytics.logEvent(
                    name: 'favourited_user',
                  );
                  await firestoreAPI.addUserFavourite(
                      uid: currentUser.id, favouriteId: account.id);
                }

                await Provider.of<AuthenticationService>(context, listen: false)
                    .updateCurrentUserData();
                setState(() {});
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildAdminSection({@required BuildContext context}) {
    AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);

    AccountService accountService =
        Provider.of<AccountService>(context, listen: false);

    GenchiUser user = accountService.currentAccount;

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
              'Main Account id: ${user.accountType == "Service Provider" ? user.mainAccountId : user.id}'),
        ),
        Center(
          child: Text('Email: ${user.email}'),
        ),
        Center(
          child: Text('Version: ${user.versionNumber}'),
        ),
        if (user.accountType == "Service Provider")
          Center(
            child: Text('Service Provider id: ${user.id}'),
          ),
        if (user.accountType == 'Service Provider')
          RoundedButton(
            buttonTitle: "Delete account",
            buttonColor: Color(kGenchiBlue),
            elevation: false,
            onPressed: () async {
              ///Get most up to data provider
              GenchiUser serviceProvider = accountService.currentAccount;
              bool delete = await showYesNoAlert(
                  context: context, title: 'Delete this account?');

              if (delete) {
                await FirebaseAnalytics()
                    .logEvent(name: 'provider_account_deleted');
                await firestoreAPI.deleteServiceProvider(
                    serviceProvider: serviceProvider);
                await authService.updateCurrentUserData();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.id,
                  (Route<dynamic> route) => false,
                );
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

    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(0, 1.14),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.29,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('images/Logo_Clear.png'),
                  alignment: Alignment(1.3, 0),
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.2), BlendMode.dstATop),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(
                    account.accountType,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Color(kGenchiGreen),
                  stretch: true,
                  pinned: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Stack(
                        children: [
                          Container(
                            color: Color(kGenchiGreen),
                            height: MediaQuery.of(context).size.height * 0.09,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                expandedDisplayPhoto = !expandedDisplayPhoto;
                                setState(() {});
                              },
                              child: AnimatedContainer(
                                height: expandedDisplayPhoto
                                    ? MediaQuery.of(context).size.height * 0.4
                                    : MediaQuery.of(context).size.height * 0.15,
                                duration: Duration(milliseconds: 150),
                                curve: Curves.fastOutSlowIn,
                                child: LargeDisplayPicture(
                                  imageUrl: account.displayPictureURL,
                                  height: expandedDisplayPhoto ? 0.4 : 0.15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Center(
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
                            if (account.accountType != 'Individual')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      "Category",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                              text: account.category
                                                      .toUpperCase() +
                                                  ": ",
                                              style: TextStyle(
                                                  fontSize: 22.0,
                                                  color: Color(kGenchiOrange),
                                                  fontWeight: FontWeight.w500),
                                              children: [
                                                TextSpan(
                                                    text: account.subcategory
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        color: Color(
                                                            kGenchiOrange),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500))
                                              ]),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            Container(
                              child: Text("About Me",
                                  textAlign: TextAlign.left,
                                  style: kTitleTextStyle),
                            ),
                            Divider(
                              thickness: 1,
                              height: 5,
                            ),
                            SelectableLinkify(
                                text: account.bio,
                                onOpen: _onOpenLink,
                                options: LinkifyOptions(
                                  humanize: false,
                                  defaultToHttps: true,
                                ),
                                style: kBodyTextStyle),
                            SizedBox(height: 10),
                            if (currentUser.admin)
                              buildAdminSection(context: context),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
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
