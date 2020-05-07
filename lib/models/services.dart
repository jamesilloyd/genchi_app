import 'package:flutter/material.dart';


//TODO: add logos from gdrive
//TODO: sort out plurals

const Map<String, Map> servicesMap = {
  'Barber': {
    'name' : 'Barber',
    'icon': Icons.content_cut,
  },
  'Photograhper': {
    'name' : 'Photograhper',
    'icon': Icons.photo_camera,
  },
  'Musician': {
    'name' : 'Musician',
    'icon': Icons.music_note,
  },
  'Researcher': {
    'name' : 'Researcher',
    'icon': Icons.bookmark_border,
  },
  'Other': {
    'name' : 'Other',
    'icon': Icons.accessibility_new,
  },
};


const List<String> servicesList = [
  'Barber',
  'Photograhper',
  'Musician',
  'Researcher',
  'Other',
];
