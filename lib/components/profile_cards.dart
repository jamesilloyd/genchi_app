import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';


class ProviderCard extends StatelessWidget {

  final String name;
  final ImageProvider image;
  final String service;
  final Function onTap;
  final String description;

  //ToDo: easier to pass provider class than initialise all the provider attributes
  ProviderCard({this.image, this.name, this.service = '', @required this.onTap, this.description = ''});

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
                title: Text(
                  (service != '') ? '$name - $service': name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: image,
                  radius: 30,
                  backgroundColor: Color(kGenchiCream),
                ),
                subtitle: Container(
                  child: Text(
                    description.length > 30 ? '${description.substring(0,30)}...' : description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),
                  ),
                ),
//                    trailing: Column(
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Text(
//                          time,
//                          style: TextStyle(fontSize: 12),
//                        ),
//                        hasUnreadMessage
//                            ? Container(
//                          margin: const EdgeInsets.only(top: 5.0),
//                          height: 18,
//                          width: 18,
//                          decoration: BoxDecoration(
//                              color: Color(kGenchiOrange),
//                              borderRadius: BorderRadius.all(
//                                Radius.circular(25.0),
//                              )),
//                          child: Center(
//                            child: Text(
//                              newMesssageCount.toString(),
//                              style: TextStyle(fontSize: 11),
//                            ),),
//                        )
//                            : SizedBox()
//                      ],
//                    ),
                onTap: onTap,
              ),
            ),
          ],
        ),
        Divider(
//          endIndent: 12.0,
//          indent: 12.0,
          height: 0,
//          color: Color(kGenchiBlue),
        ),
      ],
    );
  }
}
