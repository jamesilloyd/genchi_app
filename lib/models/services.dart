import 'package:flutter/material.dart';



//ToDo: probably need to make a class for service when it becomes more complex (YES)

//TODO probably need this to be stored in firebase too so that you don't need to update the app to have new configurations
const List<Map<String,String>> servicesListMap = [

  {
    'name' : 'Hairdressing',
    'plural' : 'Hairdressing',
    'imageAddress': 'images/service_icons/hairdressing.png',
  },

  {
    'name' : 'Deliverer',
    'plural' : 'Delivery Services',
    'imageAddress': 'images/service_icons/deliveries.png',
  },

  {
    'name' : 'Designer',
    'plural' : 'Designers',
    'imageAddress': 'images/service_icons/designers.png',
  },

  {
    'name' : 'Helping Hand',
    'plural' : 'Helping Hand',
    'imageAddress': 'images/service_icons/helping_hand.png',
  },

  {
    'name' : 'Photographer',
    'plural' : 'Photographers',
    'imageAddress': 'images/service_icons/photographers.png',
  },

  {
    'name' : 'Entertainment',
    'plural' : 'Entertainment',
    'imageAddress': 'images/service_icons/entertainment.png',
  },

  {
    'name' : 'Repair',
    'plural' : 'Repairs',
    'imageAddress': 'images/service_icons/repairs.png',
  },

  {
    'name' : 'Researcher',
    'plural' : 'Researchers',
    'imageAddress': 'images/service_icons/research.png',
  },

  {
    'name' : 'Sport',
    'plural' : 'Sports',
    'imageAddress': 'images/service_icons/sports.png',
  },

  {
    'name' : 'Tutor',
    'plural' : 'Tutors',
    'imageAddress': 'images/service_icons/tutors.png',
  },

  {
    'name' : 'Other',
    'plural' : 'Other',
    'imageAddress': 'images/other.png',
  },

];
