import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:genchi_app/components/circular_progress.dart';


class DisplayPicture extends StatelessWidget {

  const DisplayPicture({
    Key key,
    @required this.imageUrl,
    @required this.height,
  }) : super(key: key);

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          child: Center(
            child: imageUrl != null ? CachedNetworkImage(
//              fit: BoxFit.contain,
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(height: 50, width:50,
                  child: Center(child: CircularProgress())),
              imageBuilder: (context, imageProvider) => Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ):Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('images/Logo_Clear.png'),),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
