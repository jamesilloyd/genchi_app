import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';


//TODO: make function that will handle the different account types
class UserCard extends StatelessWidget {
  final Function onTap;
  final User user;

  UserCard({@required this.user, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                leading: user.displayPictureURL == null
                ///Show default image
                    ? CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xffC4C4C4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(
                            Icons.person,
                            color: Color(0xff585858),
                            size: 35,
                          ),
                        ),
                      )
                ///Show provider image
                    : Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(kGenchiCream),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image(
                    image: CachedNetworkImageProvider(user.displayPictureURL),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
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
                trailing: user.accountType == 'Service Provider' ? Text(
                  user.category,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 16,color: Color(kGenchiOrange)),
                ) : Text(''),
              ),
            ),
          ],
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
Widget ProviderAccountCard(
    {@required double width,
    @required Function onPressed,
    @required User serviceProvider,bool isSmallScreen = false}) {
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
                    style: TextStyle(fontSize: isSmallScreen ?  16:20 , color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    serviceProvider.category,
                    style: TextStyle(fontSize: isSmallScreen?14:18, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    serviceProvider.bio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isSmallScreen?11:14, color: Color(0xff7D7D7D)),
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

Widget AddProviderCard({@required double width, @required Function onPressed}) {
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
