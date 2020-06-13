import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

import 'package:genchi_app/screens/provider_screen.dart';

import 'package:genchi_app/components/display_picture.dart';

import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/provider.dart';

import 'package:genchi_app/services/provider_service.dart';
import 'package:genchi_app/services/authentication_service.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MyAppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppNavigationBar({@required this.barTitle});

  final String barTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Color(kGenchiBlue),
      ),
      title: Text(
        barTitle,
        style: TextStyle(
          color: Color(kGenchiBlue),
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Color(kGenchiCream),
      elevation: 2.0,
      brightness: Brightness.light,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}


class ChatNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatNavigationBar({@required this.barTitle, this.imageURL, @required this.provider});

  final String barTitle;
  final String imageURL;
  final ProviderUser provider;

  @override
  Widget build(BuildContext context) {
    final providerService = Provider.of<ProviderService>(context);
    return AppBar(
      iconTheme: IconThemeData(
        color: Color(kGenchiBlue),
      ),
      title: GestureDetector(
        onTap: () async {
          await providerService.updateCurrentProvider(provider.pid);
          Navigator.pushNamed(context, ProviderScreen.id);
        },

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Color(kGenchiCream),
              backgroundImage: imageURL != null ? CachedNetworkImageProvider(imageURL) : AssetImage("images/Logo_Clear.png"),
            ),
            SizedBox(width: 10),
            Text(
              barTitle,
              style: TextStyle(
                color: Color(kGenchiBlue),
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(kGenchiCream),
      elevation: 2.0,
      brightness: Brightness.light,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}



