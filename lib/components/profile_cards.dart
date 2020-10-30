import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/display_picture.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';

class UserCard extends StatelessWidget {
  final Function onTap;
  final GenchiUser user;

  UserCard({@required this.user, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: ListTile(
            // dense: true,
            shape: Border.all(color: Colors.black, width: 2),
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            title: Text(
              user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            leading: ListDisplayPicture(
              imageUrl: user.displayPictureURL,
              height: 56,
            ),

            subtitle: Container(
              child: Text(
                user.bio,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
            onTap: onTap,
            trailing: user.accountType != 'Individual'
                ? Text(
                    user.accountType == 'Group'
                        ? user.subcategory
                        : user.category,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 16, color: Color(kGenchiOrange)),
                  )
                : Text(''),
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
      ],
    );
  }
}

///These are the cards that will appear on a user's profile tab
class ProviderAccountCard extends StatelessWidget {

  final double width;
  final Function onPressed;
  final GenchiUser serviceProvider;
  final bool isSmallScreen;

  ProviderAccountCard({@required this.width, @required this.onPressed, @required this.serviceProvider,this.isSmallScreen = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: Center(
        child: Container(
          width: width,
          height: width / 1.77,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Color(kGenchiLightOrange),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 2.0), //(x,y)
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                ),
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: FlatButton(
              onPressed: onPressed,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
//                  fit: BoxFit.fitWidth,
                    child: Text(
                      serviceProvider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 20, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      serviceProvider.category,
                      style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 18, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      serviceProvider.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 14,
                          color: Color(0xff7D7D7D)),
                    ),
                  ),
                  Container(
                    height: 5,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class AddProviderCard extends StatelessWidget {

  final double width;

  final Function onPressed;

  AddProviderCard({@required this.width, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: Center(
        child: Container(
          width: width,
          height: width / 1.77,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Color(kGenchiLightOrange),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 2.0), //(x,y)
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                ),
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: FlatButton(
              onPressed: onPressed,
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


