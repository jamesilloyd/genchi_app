import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:stripe_payment/stripe_payment.dart';

class TestScreen extends StatefulWidget {
  static const id = 'test_screen';

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  FirestoreAPIService firestoreApi = FirestoreAPIService();

  PanelController panelController = PanelController();
  bool spinner = false;

  String text = 'Click the button to start the payment';
  //TODO: MUST GET THE AMOUNTS FROM FIREBASE
  //TODO: there is the added step of needing to create the customers connect account?
  //TODO: would also need to save their bank details for future payments (bit more working out to be done...)
  double totalCost = 20.0;
  double tip = 1.0;
  double tax = 0.0;
  double taxPercent = 0.2;
  int amount = 0;
  bool showSpinner = false;
  String url =
      'https://us-central1-genchi-c96c1.cloudfunctions.net/StripePI';



  void checkIfNativePayReady() async {
    print('started to check if native pay ready');
    bool deviceSupportNativePay = await StripePayment.deviceSupportsNativePay();
    bool isNativeReady = await StripePayment.canMakeNativePayPayments(
        ['american_express', 'visa', 'maestro', 'master_card']);


    deviceSupportNativePay && isNativeReady
    ? createPaymentMethodNative()
        : createPaymentMethod();
  }

  Future<void> createPaymentMethodNative() async {
    print('started NATIVE payment...');
    List<ApplePayItem> items = [];
    items.add(ApplePayItem(
      label: 'Demo Order',
      amount: totalCost.toString(),
    ));
    if (tip != 0.0)
      items.add(ApplePayItem(
        label: 'Tip',
        amount: tip.toString(),
      ));
    if (taxPercent != 0.0) {
      tax = ((totalCost * taxPercent) * 100).ceil() / 100;
      items.add(ApplePayItem(
        label: 'Tax',
        amount: tax.toString(),
      ));
    }
    items.add(ApplePayItem(
      label: 'GENCHI LTD',
      amount: (totalCost + tip + tax).toString(),
    ));
    amount = ((totalCost + tip + tax) * 100).toInt();
    print('amount in pence/cent which will be charged = $amount');
    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    Token token = await StripePayment.paymentRequestWithNativePay(
      androidPayOptions: AndroidPayPaymentRequest(
        totalPrice: (totalCost + tax + tip).toStringAsFixed(2),
        currencyCode: 'GBP',
      ),
      applePayOptions: ApplePayPaymentOptions(
        countryCode: 'GB',
        currencyCode: 'GBP',
        items: items,
      ),
    );
    paymentMethod = await StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: CreditCard(
          token: token.tokenId,
        ),
      ),
    );
    paymentMethod != null
        ? processPaymentAsDirectCharge(paymentMethod)
        : showDialog(
        context: context,
        builder: (BuildContext context) => ShowDialogToDismiss(
            title: 'Error',
            content:
            'It is not possible to pay with this card. Please try again with a different card',
            buttonText: 'CLOSE'));
  }


  Future<void> createPaymentMethod() async {
    tax = ((totalCost * taxPercent) * 100).ceil() / 100;
    amount = ((totalCost + tip + tax) * 100).toInt();
    print('amount in pence/cent which will be charged = $amount');
    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    paymentMethod = await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) {
      return paymentMethod;
    }).catchError((e) {
      print('Error Card: ${e.toString()}');
    });
    paymentMethod != null
        ? processPaymentAsDirectCharge(paymentMethod)
        : showDialog(
        context: context,
        builder: (BuildContext context) => ShowDialogToDismiss(
            title: 'Error',
            content:
            'It is not possible to pay with this card. Please try again with a different card',
            buttonText: 'CLOSE'));
  }


  Future<void> processPaymentAsDirectCharge(PaymentMethod paymentMethod) async {
    setState(() {
      showSpinner = true;
    });
    //step 2: request to create PaymentIntent, attempt to confirm the payment & return PaymentIntent
    http.Response response = await http
        .post(Uri.parse('$url?amount=$amount&currency=GBP&paym=${paymentMethod.id}'));
    print('Now i decode');
    if (response.body != null && response.body != 'error') {
      final paymentIntentX = jsonDecode(response.body);
      print(paymentIntentX);
      final status = paymentIntentX['paymentIntent']['status'];
      print("Status is: $status");
      //TODO: what follows is absolutely disgusting, must refactor....
      //step 3: check if payment was succesfully confirmed
      if (status == 'succeeded') {
        //payment was confirmed by the server without need for further authentification
        StripePayment.completeNativePayRequest();
        setState(() {
          text =
          'Payment completed. ${paymentIntentX['paymentIntent']['amount'].toString()}p succesfully charged';
          showSpinner = false;
        });
      } else {
        //step 4: there is a need to authenticate
        await StripePayment.confirmPaymentIntent(PaymentIntent(
            paymentMethodId: paymentIntentX['paymentIntent']
            ['payment_method'],
            clientSecret: paymentIntentX['paymentIntent']['client_secret']))
            .then(
              (PaymentIntentResult paymentIntentResult) async {
            //This code will be executed if the authentication is successful
            //step 5: request the server to confirm the payment with
            final statusFinal = paymentIntentResult.status;
            if (statusFinal == 'succeeded') {
              StripePayment.completeNativePayRequest();
              setState(() {
                showSpinner = false;
              });
            } else if (statusFinal == 'processing') {
              StripePayment.cancelNativePayRequest();
              setState(() {
                showSpinner = false;
              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) => ShowDialogToDismiss(
                      title: 'Warning',
                      content:
                      'The payment is still in \'processing\' state. This is unusual. Please contact us',
                      buttonText: 'CLOSE'));
            } else {
              StripePayment.cancelNativePayRequest();
              setState(() {
                showSpinner = false;
              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) => ShowDialogToDismiss(
                      title: 'Error',
                      content:
                      'There was an error to confirm the payment. Details: $statusFinal',
                      buttonText: 'CLOSE'));
            }
          },
          //If Authentication fails, a PlatformException will be raised which can be handled here
        ).catchError((e) {
          //case B1
          StripePayment.cancelNativePayRequest();
          setState(() {
            showSpinner = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) => ShowDialogToDismiss(
                  title: 'Error',
                  content:
                  'There was an error to confirm the payment. Please try again with another card',
                  buttonText: 'CLOSE'));
        });
      }
    } else {
      //case A
      StripePayment.cancelNativePayRequest();
      setState(() {
        showSpinner = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) => ShowDialogToDismiss(
              title: 'Error',
              content:
              'There was an error in creating the payment. Please try again with another card',
              buttonText: 'CLOSE'));
    }
  }



  @override
  initState() {
    super.initState();
    StripePayment.setOptions(StripeOptions(
        publishableKey:
        "pk_test_51HQIzJKtrOMGiKFz2ykOuylFiRwaLdPvnGvm8I77167Ah133uEI0Ha2toiztJnMcqDhmZkEzDiAJmrA4Tmg1Hykc00MPd2xUJ2",
        merchantId: "merchant.com.genchi.genchi",
        //TODO Change to "production"
        androidPayMode: 'test'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Center(
                  child: ElevatedButton(
                    child: Text(text),
                    onPressed:() {
                      checkIfNativePayReady();
                    },
                  ),
                ),


              ]),
        ),
      ),
    );
  }
}

class ShowDialogToDismiss extends StatelessWidget {
  final String content;
  final String title;
  final String buttonText;

  ShowDialogToDismiss({this.title, this.buttonText, this.content});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return AlertDialog(
        title: new Text(
          title,
        ),
        content: new Text(
          this.content,
        ),
        actions: <Widget>[
          new TextButton(
            child: new Text(
              buttonText,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
          title: Text(
            title,
          ),
          content: new Text(
            this.content,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: new Text(
                buttonText[0].toUpperCase() +
                    buttonText.substring(1).toLowerCase(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]);
    }
  }
}
