import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatefulWidget {
  static const id = 'payment_success_screen';

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Payment Success 😃')),
    );
  }
}
