import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:genchi_app/components/circular_progress.dart';
import 'package:genchi_app/components/rounded_button.dart';
import 'package:genchi_app/constants.dart';
import 'package:genchi_app/models/screen_arguments.dart';
import 'package:genchi_app/models/task.dart';
import 'package:genchi_app/models/user.dart';
import 'package:genchi_app/screens/payment_success_screen.dart';
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
import 'package:url_launcher/url_launcher.dart';

class PayGenchiScreen extends StatefulWidget {
  static const id = 'pay_genchi_screen';

  @override
  _PayGenchiScreenState createState() => _PayGenchiScreenState();
}

class _PayGenchiScreenState extends State<PayGenchiScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirestoreAPIService firestoreApi = FirestoreAPIService();

  FirebaseAnalytics analytics = FirebaseAnalytics();
  FirestoreAPIService firestoreAPI = FirestoreAPIService();

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
  bool readyToPay = false;

  Task task;

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
      readyToPay = true;
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
    setState(() {
      showSpinner = true;
    });

    try {
      AuthenticationService authProvider =
          Provider.of<AuthenticationService>(context, listen: false);
      GenchiUser currentUser = authProvider.currentUser;

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

          await analytics.logEvent(name: 'job_created');

          await firestoreAPI.addTask(task: task, hirerId: currentUser.id);

          ///If there is a draft saved in the user, delete it
          if (currentUser.draftJob.isNotEmpty) {
            currentUser.draftJob = {};
            await firestoreAPI.updateUser(
                user: currentUser, uid: currentUser.id);
          }

          ///update the user
          await authProvider.updateCurrentUserData();
          setState(() {
            showSpinner = false;
          });
          Navigator.pushNamed(context, PaymentSuccessScreen.id);
        } else if (result.status == 'processing') {
          StripePayment.cancelNativePayRequest();
          setState(() {
            showSpinner = false;
          });

          showDialogBox(
            context: context,
            title: 'Warning',
            body:
                'The payment is still in \'processing\' state. This is unusual. Please contact us',
          );
        } else {
          StripePayment.cancelNativePayRequest();
          setState(() {
            showSpinner = false;
          });

          showDialogBox(
              context: context,
              title: 'Error',
              body:
                  'There was an error with the payment. Please try again. If the problem persists, please contact us.');
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        showSpinner = false;
      });
      StripePayment.cancelNativePayRequest();
      showDialogBox(
          context: context,
          title: 'Error',
          body:
              'There was an error with the payment. Please try again. If the problem persists, please contact us.');
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
    final PayGenchiScreenArguments args =
        ModalRoute.of(context).settings.arguments;

    task = args.taskToPost;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          progressIndicator: CircularProgress(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Color(kGenchiGreen),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Color(kGenchiCream),
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'images/Logo_Clear.png',
                                    ),
                                  )),
                            ),
                            Text(
                              'GENCHI LTD',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        FutureBuilder(
                            future: firestoreApi.getPaymentAmount(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                amount = snapshot.data['amount'];
                                amountString = snapshot.data['amountString'];

                                return Column(
                                  children: [
                                    Text(
                                      'Post Paid Opportunity',
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.center,
                                    //   children: [
                                    //     SizedBox(
                                    //       width: 48,
                                    //     ),
                                    //
                                    //     // IconButton(
                                    //     //   padding: const EdgeInsets.all(0),
                                    //     //   icon: Icon(
                                    //     //     Icons.help_outline_outlined,
                                    //     //     size: 18,
                                    //     //     color: Colors.black,
                                    //     //   ),
                                    //     //   onPressed: () async {
                                    //     //     await showDialogBox(
                                    //     //         context: context,
                                    //     //         title: 'Genchi Charge',
                                    //     //         body:
                                    //     //             '{Insert reason why we charge}');
                                    //     //   },
                                    //     // ),
                                    //   ],
                                    // ),
                                    Text(
                                      '£$amountString',
                                      style: TextStyle(fontSize: 40),
                                    ),
                                  ],
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                ///Native pay check
                FutureBuilder(
                  future: nativePayFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MaterialButton(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            height: 42.0,
                            minWidth: 200,
                            color: Color(kGenchiLightOrange),
                            onPressed: () async {
                              if (task != null) {
                                await createPaymentMethodNative();
                              } else {
                                showDialogBox(
                                    context: context,
                                    title:
                                        'There was a problem with your task details, please contact us at hello@genchi.app');
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            child: Platform.isIOS
                                ? Image.asset('images/apple_pay.png',
                                    height: 25)
                                : Image.asset('images/google_pay.png',
                                    height: 25),
                            splashColor: Colors.black12,
                            highlightColor: Colors.transparent,
                            elevation: 2,
                            highlightElevation: 5,
                            // hoverElevation: 20,
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
                SizedBox(height: 30),

                ///Card payment
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MaterialButton(
                    color: Color(kGenchiLightGreen),
                    height: 42.0,
                    minWidth: 200,
                    splashColor: Colors.black12,
                    highlightColor: Colors.transparent,
                    elevation: 2,
                    highlightElevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                    child: Container(
                      child: Text(
                        'Press to Enter Card Information',
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
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
                    child: MaterialButton(
                  color: Color(kGenchiLightOrange),
                  height: 42.0,
                  minWidth: 200,
                  splashColor: Colors.black12,
                  highlightColor: Colors.transparent,
                  elevation: 2,
                  highlightElevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                  child: Container(
                    child: Text(
                      'Pay with card',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  onPressed: () async {
                    if (paymentMethod != null && readyToPay && task != null) {
                      //TODO: error / success handling!

                      await processPaymentAsDirectCharge(paymentMethod);
                    } else {
                      showDialogBox(
                          context: context, title: 'Enter card details first');
                      print(
                          'Please enter card details or look to see if there is a problem with the card details');
                    }
                  },
                )),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by',
                      style: TextStyle(fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (await canLaunch('https://stripe.com/en-gb/about')) {
                          await launch('https://stripe.com/en-gb/about');
                        } else {
                          print("Could not open URL");
                        }
                      },
                      child: Image.asset(
                        'images/stripe.png',
                        height: 25,
                      ),
                    )
                  ],
                )
              ]),
        ),
      ),
    );
  }
}
