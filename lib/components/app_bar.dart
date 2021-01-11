import 'package:flutter/material.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/user_screen.dart';

import 'package:genchi_app/services/account_service.dart';

import 'package:provider/provider.dart';

class BasicAppNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BasicAppNavigationBar({@required this.barTitle});

  final String barTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      centerTitle: true,
      title: Text(
        barTitle,
        maxLines: 1,
        style: TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Color(kGenchiGreen),
      elevation: 2.0,
      brightness: Brightness.light,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}

class ChatNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatNavigationBar({
    @required this.user,
    @required this.otherUser,
  });

  final GenchiUser user;
  final GenchiUser otherUser;

  @override
  Widget build(BuildContext context) {
    final accountService = Provider.of<AccountService>(context);
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      title: GestureDetector(
        onTap: () async {
          await accountService.updateCurrentAccount(id: otherUser.id);
          Navigator.pushNamed(context, UserScreen.id);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListDisplayPicture(imageUrl: otherUser.displayPictureURL, height: 50),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                otherUser.name,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.white),
          child: Container(
            height: 60.0,
            color: Color(kGenchiCream),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () async {
                await accountService.updateCurrentAccount(id: user.id);
                Navigator.pushNamed(context, UserScreen.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        user.accountType == 'Service Provider'
                            ? '${user.name} - ${user.category}'
                            : user.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color(kGenchiGreen),
      elevation: 3,
      brightness: Brightness.light,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight + 60);
}
