import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';

/// Only for demo purposes!
/// Don't you dare do it in real apps!
class Server {
  Future<String> createCheckout() async {
    final auth = 'Basic ' +
        base64Encode(utf8.encode(
            'sk_test_51HQIzJKtrOMGiKFzhHU6NEtNfv6u1PITSwzG77loW0NBVUCwrXuem8yb6PJwiaj84u9kqxpjUKpBngZDalwfJ9JB00C41qM4sW'));

    final body = {
      'line_items': [
        {
          'price': "price_1ItXuhKtrOMGiKFzX4yO9xdt",
          'quantity': 2,
        }
      ],
      'mode': 'payment',
      'payment_method_types': [['card']],
      'success_url': 'https://genchi.app',
      'cancel_url': 'https://genchi.app',
    };

    String formBody = Uri.encodeQueryComponent(
      json.encode(body),
    );

    List<int> bodyBytes = utf8.encode(formBody);

    String encodedBody = body.keys.map((key) => "$key=${body[key]}").join("&");

    try {
      // final response = await http.post(
      //   Uri.parse("https://api.stripe.com/v1/checkout/sessions"),
      //   headers: {
      //     HttpHeaders.authorizationHeader: auth,
      //     HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      //     // HttpHeaders.contentLengthHeader:bodyBytes.length.toString()
      //   },
      //   // body: "mode=payment&payment_method_types=[card]&"
      //   body: formBody,
      //
      //   encoding: Encoding.getByName('utf-8'),
      // );
      // print(response);
      final result = await Dio().post(
        "https://api.stripe.com/v1/checkout/sessions",
        data: body,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: auth,
            HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
          },
          contentType: "application/x-www-form-urlencoded",
        ),
      );

      // final result = jsonDecode(response.body);
      // print(result);
      return result.data['id'];

      // data['id'];
    } on DioError catch (e, s) {
      print(e.response);
      throw e;
    }
  }
}
