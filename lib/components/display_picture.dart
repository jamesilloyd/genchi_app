import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/constants.dart';


class DisplayPicture extends StatelessWidget {

  const DisplayPicture({
    @required this.imageUrl,
    @required this.height,
    this.isEdit = false,
  });

  final String imageUrl;
  final double height;
  final bool isEdit;


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          child: Center(
            child: imageUrl != null ? CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(height: 50, width:50,
                  child: Container(child: Center(child: CircularProgress()))),
              imageBuilder: (context, imageProvider) => Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ) : Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffC4C4C4),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(
                  isEdit ? Icons.add : Icons.person,
                  color: isEdit ? Colors.black : Color(0xff585858),
                  size: isEdit ? 12 : 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
