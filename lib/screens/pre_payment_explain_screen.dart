import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:genchi_app/components/app_bar.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/post_task_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PrePaymentScreen extends StatelessWidget {
  static const id = 'pre_payment_screen';

  const PrePaymentScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppNavigationBar(barTitle: 'Genchi Business'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'How it works',
                    style: TextStyle(fontSize: 40),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "1. You fill out the opportunity's details\n\n2. Our team reviews it and ensures the best applicants apply\n\n3. You manage and choose applicants through the app",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              RoundedButton(
                  buttonTitle: 'Fill out opportunity details (£20)',
                  fontColor: Colors.black,
                  buttonColor: Color(kGenchiLightOrange),
                  onPressed: () {
                    Navigator.pushNamed(context, PostTaskScreen.id);
                  }),
              Column(
                children: [
                  Text(
                    'Any Questions?',
                    style: TextStyle(fontSize: 22),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SelectableLinkify(
                    text: 'Feel free to reach out to us at hello@genchi.app',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22),
                    onOpen: _onOpenLink,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _onOpenLink(LinkableElement link) async {
  if (link.runtimeType == EmailElement) {
    launch('mailto:${link.text}?subject=Genchi%20for%20Business');
  } else {
    String url = link.url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $link';
    }
  }
}
