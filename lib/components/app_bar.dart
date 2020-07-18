import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

import 'package:genchi_app/screens/provider_screen.dart';

import 'package:genchi_app/models/provider.dart';

import 'package:genchi_app/services/provider_service.dart';
import 'package:genchi_app/services/authentication_service.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  const ChatNavigationBar(
      {@required this.barTitle, this.imageURL, @required this.provider, this.userIsProvider = false});

  final String barTitle;
  final String imageURL;
  final ProviderUser provider;
  final bool userIsProvider;

  @override
  Widget build(BuildContext context) {
    final providerService = Provider.of<ProviderService>(context);
    return AppBar(
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
                await providerService.updateCurrentProvider(provider.pid);
                Navigator.pushNamed(context, ProviderScreen.id);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      if(userIsProvider) Text(
                        provider.name,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        provider.type,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(kGenchiOrange)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      title: GestureDetector(
        onTap: () async {
          //TODO show hirer view if they are a hirer else show provider view
          if(!userIsProvider) {
            ///User is Hiring
            await providerService.updateCurrentProvider(provider.pid);
            Navigator.pushNamed(context, ProviderScreen.id);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            imageURL != null
                ? CircleAvatar(
                    backgroundColor: Color(kGenchiCream),
                    backgroundImage: CachedNetworkImageProvider(imageURL),
                  )
                : CircleAvatar(
                    backgroundColor: Color(0xffC4C4C4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(
                        Icons.person,
                        color: Color(0xff585858),
                        size: 25,
                      ),
                    ),
                  ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                barTitle,
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
      backgroundColor: Color(kGenchiGreen),
      elevation: 5,
      brightness: Brightness.light,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight + 60);
}
