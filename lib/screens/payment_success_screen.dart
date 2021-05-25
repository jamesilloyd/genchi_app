import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/screens/home_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  static const id = 'payment_success_screen';

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color(kGenchiGreen),
        title: Text('Success',maxLines: 1,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Payment and Posting Success!\n🎉🎉🎉\n\nThank you for sharing your opportunity with Genchi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            RoundedButton(

              buttonTitle: 'Back to Home Screen',
                buttonColor: Color(kGenchiLightOrange),
                fontColor: Colors.black,

                onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.id, (Route<dynamic> route) => false);
            })
          ],
        ),
      ),
    );
  }
}
