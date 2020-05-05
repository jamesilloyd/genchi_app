import 'package:flutter/material.dart';
import 'package:genchi_app/components/app_bar.dart';

class SearchProviderScreen extends StatefulWidget {
  static const String id = "search_provider_screen";
  @override
  _SearchProviderScreenState createState() => _SearchProviderScreenState();
}

class _SearchProviderScreenState extends State<SearchProviderScreen> {
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: MyAppNavigationBar(barTitle: "Photographers"),
      body: Center(
        child: Text(
            "Search photographers",
            style: TextStyle(
              fontSize: 30.0,
            )
        ),
      ),
    );
  }
}
