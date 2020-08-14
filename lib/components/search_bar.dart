import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/search_manual_screen.dart';


class SearchBar extends StatelessWidget {
  const SearchBar({
    Key key,
    @required this.searchTextController,
    @required this.onSubmitted,
  }) : super(key: key);

  final TextEditingController searchTextController;
  final Function onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.left,
      onSubmitted: onSubmitted,
      controller: searchTextController,
      decoration: InputDecoration(
        hintText: "Search",
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        fillColor: Color(kGenchiCream),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(kGenchiBlue), width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(kGenchiBlue), width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
      cursorColor: Color(kGenchiOrange),
    );
  }
}


//TODO: Turn this into a button
class SearchBarButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: (){
        Navigator.pushNamed(context, SearchManualScreen.id);
      },
      autocorrect: false,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.left,
      onChanged: (value) {},
      decoration: InputDecoration(
        hintText: "Search",
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        fillColor: Color(kGenchiCream),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(kGenchiBlue), width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(kGenchiBlue), width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
      ),
      cursorColor: Color(kGenchiOrange),
    );
  }
}