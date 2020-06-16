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
                onTap: onTap,
              ),
            ),
          ],
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }
}
