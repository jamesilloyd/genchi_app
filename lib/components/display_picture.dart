import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:genchi_app/components/circular_progress.dart';


class DisplayPicture extends StatelessWidget {

  const DisplayPicture({
    Key key,
    @required this.imageUrl,
    @required this.height,
    this.border = false,
    this.isEdit = false,
  }) : super(key: key);

  final String imageUrl;
  final double height;
  final bool border;
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
//              fit: BoxFit.contain,
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(height: 50, width:50,
                  child: Container(child: Center(child: CircularProgress()))),
              imageBuilder: (context, imageProvider) => Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: border ? Border.all(color: Color(0xff585858),width: 0.75):null,
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ):Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffC4C4C4),
                border: border ? Border.all(color: Color(0xff585858),width: 0.75):null,
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
