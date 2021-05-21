import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/paymentSuccessScreen.dart';
import 'package:genchi_app/services/firestore_api_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:genchi_app/services/authentication_service.dart';
import 'package:genchi_app/components/profile_option_tile.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:genchi_app/components/platform_alerts.dart';
import 'package:flutter_credit_card/credit_card_model.dart';

import 'package:stripe_payment/stripe_payment.dart';

class PayGenchiScreen extends StatefulWidget {
  static const id = 'pay_genchi_screen';

  @override
  _PayGenchiScreenState createState() => _PayGenchiScreenState();
}

class _PayGenchiScreenState extends State<PayGenchiScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirestoreAPIService firestoreApi = FirestoreAPIService();


  bool spinner = false;

  String text = 'Click the button to start the payment';
  double totalCost = 20.0;
  double tip = 1.0;
  double tax = 0.0;
  double taxPercent = 0.2;
  int amount = 0;
  String amountString;
  bool showSpinner = false;
  String paymentId = 'IyPQrb69MUSNRWvjgzPJ';
  PaymentMethod paymentMethod;
  String cardNumber;
  bool cardEnteredCorrectly;
  String cvc;

  Future nativePayFuture;

  CreditCard card = CreditCard();

  Future<bool> checkIfNativePayReady() async {
    print('started to check if native pay ready');
    bool deviceSupportNativePay = await StripePayment.deviceSupportsNativePay();
    bool isNativeReady = await StripePayment.canMakeNativePayPayments(
        ['american_express', 'visa', 'maestro', 'master_card']);

    if (deviceSupportNativePay && isNativeReady) {
      print('native pay ready');
      return true;
    } else {
      print('native pay not ready');
      return false;
    }
  }

  Future<void> createPaymentMethodWithCard() async {
    // tax = ((totalCost * taxPercent) * 100).ceil() / 100;
    // amount = ((totalCost + tip + tax) * 100).toInt();
    print('amount in pence/cent which will be charged = $amount');
    //step 1: add card
    try {
      paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());
      //TODO: return something in the UI
      card = paymentMethod.card;
      cardNumber = "**** **** **** ${card.last4}";
      cvc = "***";
      cardEnteredCorrectly = true;
      setState(() {});
    } catch (e) {
      print('Error Card: ${e.toString()}');
      //TODO  Return something in the UI
      paymentMethod = null;
      cardEnteredCorrectly = false;
      card = CreditCard();
      cardNumber = null;
      cvc = null;
      setState(() {});
    }

    // //TODO: this appears if the user cancels
    // paymentMethod != null
    //     ? processPaymentAsDirectCharge(paymentMethod)
    //     : showDialog(
    //         context: context,
    //         builder: (BuildContext context) => ShowDialogToDismiss(
    //             title: 'Error',
    //             content:
    //                 'It is not possible to pay with this card. Please try again with a different card',
    //             buttonText: 'CLOSE'));
  }

  Future<void> createPaymentMethodNative() async {
    print('started NATIVE payment...');
    List<ApplePayItem> items = [];
    // items.add(ApplePayItem(
    //   label: 'Demo Order',
    //   amount: totalCost.toString(),
    // ));
    // if (tip != 0.0)
    //   items.add(ApplePayItem(
    //     label: 'Tip',
    //     amount: tip.toString(),
    //   ));
    // if (taxPercent != 0.0) {
    //   tax = ((totalCost * taxPercent) * 100).ceil() / 100;
    //   items.add(ApplePayItem(
    //     label: 'Tax',
    //     amount: tax.toString(),
    //   ));
    // }
    items.add(ApplePayItem(label: 'GENCHI LTD', amount: amountString
        // amount: (totalCost + tip + tax).toString(),
        ));
    // amount = ((totalCost + tip + tax) * 100).toInt();
    print('amount in pence which will be charged = $amount');
    //step 1: add card
    PaymentMethod paymentMethod = PaymentMethod();
    Token token = await StripePayment.paymentRequestWithNativePay(
      androidPayOptions: AndroidPayPaymentRequest(
        totalPrice: amountString,
        // totalPrice: (totalCost + tax + tip).toStringAsFixed(2),
        currencyCode: 'GBP',
      ),
      applePayOptions: ApplePayPaymentOptions(
        countryCode: 'GB',
        currencyCode: 'GBP',
        items: items,
      ),
    );

    try {
      paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
          card: CreditCard(
            token: token.tokenId,
          ),
        ),
      );

      if (paymentMethod != null) {
        await processPaymentAsDirectCharge(paymentMethod);
      }
    } catch (e) {
      print('Error: $e');
      StripePayment.cancelNativePayRequest();
      showDialogBox(
          context: context,
          title: 'Error',
          body:
              'There was an error with the payment. Please try on another card.');
    }
  }

  Future<void> processPaymentAsDirectCharge(PaymentMethod paymentMethod) async {
    try {
      GenchiUser currentUser =
          Provider.of<AuthenticationService>(context, listen: false)
              .currentUser;

      http.Response response = await http.post(Uri.parse(
          'https://us-central1-genchi-c96c1.cloudfunctions.net/StripeDirectPayment?email=${currentUser.email}&paymentId=$paymentId'));

      print(response.body);
      print('Now i decode');
      if (response.body != null && response.body != 'error') {
        final paymentIntentX = jsonDecode(response.body);
        final clientSecret = paymentIntentX['clientSecret'];
        PaymentIntent paymentIntent = PaymentIntent(
            paymentMethodId: paymentMethod.id,
            clientSecret: clientSecret,
            //TODO: create return dynamic link for the user!
            returnURL: 'https://genchi.app');

        PaymentIntentResult result =
            await StripePayment.confirmPaymentIntent(paymentIntent);

        print(result);
        print(result.status);
        if (result.status == 'succeeded') {
          print('Payment completed!!!');
          StripePayment.completeNativePayRequest();
          Navigator.pushNamed(context, PaymentSuccessScreen.id);
        } else if (result.status == 'processing') {
          StripePayment.cancelNativePayRequest();

          showDialogBox(
            context: context,
            title: 'Warning',
            body:
                'The payment is still in \'processing\' state. This is unusual. Please contact us',
          );
        } else {
          StripePayment.cancelNativePayRequest();

          showDialogBox(
            context: context,
            title: 'Error',
            body: 'There was an error to confirm the payment.',
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      StripePayment.cancelNativePayRequest();
      showDialogBox(
          context: context,
          title: 'Error',
          body:
              'There was an error with the payment. Please try on another card.');
    }
  }

  @override
  initState() {
    super.initState();
    StripePayment.setOptions(StripeOptions(
        // publishableKey:
        //     "pk_live_51HQIzJKtrOMGiKFzwkMkBPsROe2dIW8W5Ot23ePGhnNvGow60PJUpA5xXHPwQUeDpTlOcGKANRJ2WGTYjaD5vI6B00nvXfp9zq",
        publishableKey:
            "pk_test_51HQIzJKtrOMGiKFz2ykOuylFiRwaLdPvnGvm8I77167Ah133uEI0Ha2toiztJnMcqDhmZkEzDiAJmrA4Tmg1Hykc00MPd2xUJ2",
        merchantId: "merchant.com.genchi.genchi",
        //TODO Change to "production"
        androidPayMode: 'production'));

    nativePayFuture = checkIfNativePayReady();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //TODO: get logo up here
                FutureBuilder(
                    future: firestoreApi.getPaymentAmount(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        amount = snapshot.data['amount'];
                        amountString = snapshot.data['amountString'];

                        return Text(
                          'Pay Genchi £$amountString',
                          style: TextStyle(fontSize: 40),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),

                SizedBox(height: 20),

                ///Native pay check
                FutureBuilder(
                  future: nativePayFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          height: 42.0,
                          width: 200.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Color(kGenchiGreen),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2))
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: TextButton(
                              onPressed: () async{
                                print('hello');
                                await createPaymentMethodNative();
                              },
                              child: Platform.isIOS ? Image.asset('images/apple_pay.png',height:25) : Image.asset('images/google_pay.png',height:25),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Divider(
                                thickness: 1,
                              )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  'Or pay with card',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                thickness: 1,
                              ))
                            ],
                          ),
                        )
                      ]);
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
                SizedBox(height: 20),

                ///Card payment
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  TextButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 37.0),
                      child: Text(
                        'Press to Enter Card Information',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    onPressed: () async {
                      await createPaymentMethodWithCard();
                    },
                  )
                ]),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    cardNumber != null ? cardNumber : 'Number',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                              color: Colors.black45,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    (card.expMonth != null
                                            ? card.expMonth.toString()
                                            : 'MM') +
                                        ' / ' +
                                        (card.expYear != null
                                            ? card.expYear.toString()
                                            : 'YY'),
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                              color: Colors.black45,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    cvc != null ? cvc : 'CVC',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: RoundedButton(
                    buttonColor: Color(kGenchiLightOrange),
                    fontColor: Colors.black,
                    buttonTitle: 'Pay with card',
                    onPressed: () async {
                      if (paymentMethod != null) {
                        //TODO: error / success handling!
                        await processPaymentAsDirectCharge(paymentMethod);
                      } else {
                        showDialogBox(
                            context: context,
                            title: 'Enter card details first');
                        print(
                            'Please enter card details or look to see if there is a problem with the card details');
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by',
                      style: TextStyle(fontSize: 14),
                    ),
                    Image.asset(
                      'images/stripe.png',
                      height: 25,
                    )
                  ],
                )
              ]),
        ),
      ),
    );
  }
}
