import 'package:flutter/material.dart';
import 'package:genchi_app/constants.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key key,
    @required this.searchTextController,
  }) : super(key: key);

  final TextEditingController searchTextController;

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
      onChanged: (value) {},
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