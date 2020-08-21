import 'package:flutter/material.dart';


class Service {

  String nameSingular;
  String namePlural;
  String imageAddress;
  ///Don't change this value
  String databaseValue;

  Service({this.nameSingular, this.namePlural, this.imageAddress, this.databaseValue});
}


List<Service> servicesList = [

  Service(nameSingular: 'Designer',
    namePlural: 'Designers',
    imageAddress: 'images/service_icons/designers.png',
    databaseValue: 'Design'
  ),
  Service(
      nameSingular: 'Journalist',
      namePlural: 'Journalists',
      imageAddress: 'images/service_icons/tutors.png',
      databaseValue: 'Journalism'
  ),
  Service(
      nameSingular: 'Photographer',
      namePlural: 'Photographers',
      imageAddress: 'images/service_icons/photographers.png',
      databaseValue: 'Photography'
  ),
  Service(
      nameSingular: 'Researcher',
      namePlural: 'Researchers',
      imageAddress: 'images/service_icons/research.png',
      databaseValue: 'Research'
  ),
  Service(
      nameSingular: 'Software',
      namePlural: 'Software',
      //TODO add this
      imageAddress: 'images/service_icons/software.png',
      databaseValue: 'Software'
  ),
  Service(
      nameSingular: 'Other',
      namePlural: 'Other',
      imageAddress: 'images/service_icons/other.png',
      databaseValue: 'Other'
  ),

];
